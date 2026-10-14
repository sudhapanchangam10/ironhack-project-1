
using System;
using System.Data.Common;
using System.Linq;
using System.Net;
using System.Net.Sockets;
using System.Threading;
using Newtonsoft.Json;
using Npgsql;
using StackExchange.Redis;

namespace Worker
{
    public class Program
    {
        public static int Main(string[] args)
        {
            try
            {
                // Read database configuration
                var dbHost = Environment.GetEnvironmentVariable("DB_HOST") ?? "db";
                var dbUsername = Environment.GetEnvironmentVariable("DB_USERNAME") ?? "postgres";
                var dbPassword = Environment.GetEnvironmentVariable("DB_PASSWORD") ?? "postgres";
                var dbName = Environment.GetEnvironmentVariable("DB_NAME") ?? "postgres";

                // Read Redis configuration
                var redisHost = Environment.GetEnvironmentVariable("REDIS_HOST") ?? "redis";

                var pgConnectionString =
                    $"Server={dbHost};Username={dbUsername};Password={dbPassword};Database={dbName}";

                Console.WriteLine($"Database connection string: Server={dbHost};Username={dbUsername};Database={dbName}");

                var redisConnectionString = redisHost;

                var pgsql = OpenDbConnection(pgConnectionString);
                var redisConn = OpenRedisConnection(redisConnectionString);
                var redis = redisConn.GetDatabase();

                var keepAliveCommand = pgsql.CreateCommand();
                keepAliveCommand.CommandText = "SELECT 1";

                var definition = new { vote = "", voter_id = "" };

                while (true)
                {
                    Thread.Sleep(100);

                    // Reconnect to Redis if the connection is lost
                    if (!redisConn.IsConnected)
                    {
                        Console.WriteLine("Reconnecting Redis");
                        redisConn = OpenRedisConnection(redisConnectionString);
                        redis = redisConn.GetDatabase();
                    }

                    string json = redis.ListLeftPopAsync("votes").Result;

                    if (json != null)
                    {
                        var vote = JsonConvert.DeserializeAnonymousType(json, definition);

                        if (vote == null)
                        {
                            continue;
                        }

                        Console.WriteLine($"Processing vote for '{vote.vote}' by '{vote.voter_id}'");

                        if (pgsql.State != System.Data.ConnectionState.Open)
                        {
                            Console.WriteLine("Reconnecting DB");
                            pgsql = OpenDbConnection(pgConnectionString);
                            keepAliveCommand = pgsql.CreateCommand();
                            keepAliveCommand.CommandText = "SELECT 1";
                        }

                        UpdateVote(pgsql, vote.voter_id, vote.vote);
                    }
                    else
                    {
                        keepAliveCommand.ExecuteNonQuery();
                    }
                }
            }
            catch (Exception ex)
            {
                Console.Error.WriteLine(ex);
                return 1;
            }
        }

        private static NpgsqlConnection OpenDbConnection(string connectionString)
        {
            while (true)
            {
                try
                {
                    var connection = new NpgsqlConnection(connectionString);
                    connection.Open();

                    Console.Error.WriteLine("Connected to db");

                    using var command = connection.CreateCommand();
                    command.CommandText = @"
                        CREATE TABLE IF NOT EXISTS votes (
                            id VARCHAR(255) NOT NULL,
                            vote VARCHAR(255) NOT NULL
                        )";
                    command.ExecuteNonQuery();

                    return connection;
                }
                catch (SocketException)
                {
                    Console.Error.WriteLine("Waiting for db");
                    Thread.Sleep(1000);
                }
                catch (DbException)
                {
                    Console.Error.WriteLine("Waiting for db");
                    Thread.Sleep(1000);
                }
            }
        }

        private static ConnectionMultiplexer OpenRedisConnection(string hostname)
        {
            // Resolve a hostname only when the setting is not already an IP address.
            var ipAddress = GetIp(hostname);

            Console.WriteLine($"Found redis at {ipAddress}");

            while (true)
            {
                try
                {
                    Console.Error.WriteLine("Connecting to redis");
                    return ConnectionMultiplexer.Connect($"{ipAddress}:6379");
                }
                catch (RedisConnectionException)
                {
                    Console.Error.WriteLine("Waiting for redis");
                    Thread.Sleep(1000);
                }
            }
        }

        private static string GetIp(string hostname)
        {
            if (IPAddress.TryParse(hostname, out var ipAddress))
            {
                return ipAddress.ToString();
            }

            return Dns.GetHostEntryAsync(hostname)
                .GetAwaiter()
                .GetResult()
                .AddressList
                .First(a => a.AddressFamily == AddressFamily.InterNetwork)
                .ToString();
        }

        private static void UpdateVote(
            NpgsqlConnection connection,
            string voterId,
            string vote)
        {
            using var command = connection.CreateCommand();

            try
            {
                command.CommandText =
                    "INSERT INTO votes (id, vote) VALUES (@id, @vote)";
                command.Parameters.AddWithValue("@id", voterId);
                command.Parameters.AddWithValue("@vote", vote);
                command.ExecuteNonQuery();
            }
            catch (DbException)
            {
                command.Parameters.Clear();
                command.CommandText =
                    "UPDATE votes SET vote = @vote WHERE id = @id";
                command.Parameters.AddWithValue("@id", voterId);
                command.Parameters.AddWithValue("@vote", vote);
                command.ExecuteNonQuery();
            }
        }
    }
}
