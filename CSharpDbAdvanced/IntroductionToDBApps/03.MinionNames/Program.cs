using Config;
using System;
using System.Data.SqlClient;

namespace _03.MinionNames
{
    class Program
    {
        static void Main(string[] args)
        {
            using (SqlConnection connection = new SqlConnection(Configuration.connectionStringWithDatabase))
            {
                connection.Open();

                string id = Console.ReadLine();
                string existVillain = $"SELECT Name FROM Villains WHERE Id = {id}";

                using (SqlCommand command = new SqlCommand(existVillain, connection))
                {
                    if (command.ExecuteScalar() == null)
                    {
                        Console.WriteLine($"No villain with ID {id} exists in the database.");
                    }
                    else
                    {
                        string minions = $"SELECT v.Name, m.Name AS MinionName, m.Age FROM Villains v JOIN MinionsVillains mv ON v.Id = mv.VillainId JOIN Minions m ON mv.MinionId = m.Id WHERE v.Id = {id} ORDER BY m.Name";
                        using(SqlCommand commandVillain = new SqlCommand(minions, connection))
                        {
                            Console.WriteLine($"Villain: {commandVillain.ExecuteScalar()}");
                            using (SqlDataReader reader = commandVillain.ExecuteReader())
                            {
                                int counter = 1;
                                bool haveMinions = true;
                                while (reader.Read())
                                {
                                    if (reader[1] == null)
                                    {
                                        haveMinions = false;
                                        break;
                                    }
                                    Console.WriteLine($"{counter}. {reader[1]} {reader[2]}");
                                    counter++;
                                }

                                if (!haveMinions)
                                {
                                    Console.WriteLine("(no minions)");
                                }
                            }
                        }
                    }
                }


                connection.Close();
            }
        }
    }
}
