using System;
using System.Data.SqlClient;
using Config;

namespace _02.Villain_Names
{
    public class Program
    {
        public static void Main(string[] args)
        {
            using (SqlConnection connection = new SqlConnection(Configuration.connectionStringWithDatabase))
            {
                connection.Open();

                string minionsCount = @"select v.Name, count(v.Name) as MinionCount from Villains v	join MinionsVillains mv on v.Id = mv.VillainId group by v.Name having COUNT(v.Name) >= 3 order by MinionCount desc";

                using (SqlCommand command = new SqlCommand(minionsCount, connection))
                {
                    using (SqlDataReader reader = command.ExecuteReader())
                    {
                        while (reader.Read())
                        {
                            Console.WriteLine($"{reader[0]} - {reader[1]}");
                        }
                    }
                }

                connection.Close();
            }
        }
    }
}
