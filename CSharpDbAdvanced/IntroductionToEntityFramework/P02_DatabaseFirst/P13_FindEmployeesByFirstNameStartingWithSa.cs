using P02_DatabaseFirst.Data;
using P02_DatabaseFirst.Data.Models;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;

namespace P02_DatabaseFirst
{
    public class P13_FindEmployeesByFirstNameStartingWithSa
    {
        public static void Run()
        {
            using (SoftUniContext context = new SoftUniContext())
            {
                var employee = context.Employees.Where(x => x.FirstName.StartsWith("Sa"))
                                                    .Select(x => new
                                                    {
                                                        x.FirstName,
                                                        x.LastName,
                                                        x.JobTitle,
                                                        x.Salary
                                                    })
                                                    .OrderBy(x => x.FirstName)
                                                    .ThenBy(x => x.LastName)
                                                    .ToArray();

                using (StreamWriter sw = new StreamWriter("../../../FindEmployeesByFirstNameStartingWithSa.txt"))
                {
                    foreach (var e in employee)
                    {
                        sw.WriteLine($"{e.FirstName} {e.LastName} - {e.JobTitle} - (${e.Salary:f2})");
                    }
                }
            }
        }
    }
}
