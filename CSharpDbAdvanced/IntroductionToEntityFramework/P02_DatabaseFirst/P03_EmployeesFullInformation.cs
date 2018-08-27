using P02_DatabaseFirst.Data;
using P02_DatabaseFirst.Data.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace P02_DatabaseFirst
{
    public class P03_EmployeesFullInformation
    {
        public static void Run()
        {
            using (SoftUniContext context = new SoftUniContext())
            {
                var employees = context.Employees
                    .OrderBy(x => x.EmployeeId)
                    .Select(x => new Employee()
                    {
                        FirstName = x.FirstName,
                        LastName = x.LastName,
                        MiddleName = x.MiddleName,
                        JobTitle = x.JobTitle,
                        Salary = x.Salary
                    })
                    .ToArray();

                using (StreamWriter sw = new StreamWriter("../EmploeesFullInformation.txt"))
                {
                    foreach (var e in employees)
                    {
                        sw.WriteLine($"{e.FirstName} {e.LastName} {e.MiddleName} {e.JobTitle} {e.Salary:f2}");
                    }
                }
            }
        }
    }
}
