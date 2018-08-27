using P02_DatabaseFirst.Data;
using P02_DatabaseFirst.Data.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace P02_DatabaseFirst
{
    public class P04_EmployeesWithSalaryOver50000
    {
        public static void Run()
        {
            using (SoftUniContext context = new SoftUniContext())
            {
                var employees = context.Employees
                    .Where(x => x.Salary > 50000)
                    .OrderBy(x => x.FirstName)
                    .Select(x => new Employee()
                    {
                        FirstName = x.FirstName
                    })
                    .ToArray();

                using (StreamWriter sw = new StreamWriter("../EmploeesFullInformation.txt"))
                {
                    foreach (var e in employees)
                    {
                        Console.WriteLine($"{e.FirstName}");
                    }
                }
            }
        }
    }
}
