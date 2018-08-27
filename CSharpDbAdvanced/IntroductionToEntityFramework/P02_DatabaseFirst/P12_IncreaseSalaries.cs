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
    public class P12_IncreaseSalaries
    {
        public static void Run()
        {
            using (SoftUniContext context = new SoftUniContext())
            {
                var employee = context.Employees.Where(x => x.Department.Name == "Engineering" || x.Department.Name == "Tool Design" || x.Department.Name == "Marketing" || x.Department.Name == "Information Services")
                                                    .OrderBy(x => x.FirstName)
                                                    .ThenBy(x => x.LastName)
                                                    .ToArray();

                using (StreamWriter sw = new StreamWriter("../../../IncreaseSalaries.txt"))
                {
                    foreach (var e in employee)
                    {
                        e.Salary = e.Salary * 1.12M;
                        sw.WriteLine($"{e.FirstName} {e.LastName} (${e.Salary:f2})");
                    }
                }

                context.SaveChanges();
            }
        }
    }
}
