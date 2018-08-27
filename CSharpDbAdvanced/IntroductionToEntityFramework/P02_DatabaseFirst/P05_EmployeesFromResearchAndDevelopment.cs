using P02_DatabaseFirst.Data;
using P02_DatabaseFirst.Data.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace P02_DatabaseFirst
{
    public class P05_EmployeesFromResearchAndDevelopment
    {
        public static void Run()
        {
            using (SoftUniContext context = new SoftUniContext())
            {
                var employees = context.Employees
                    .Where(x => x.Department.Name == "Research and Development")
                    .OrderBy(y => y.Salary)
                    .ThenByDescending(x => x.FirstName)
                    .Select(x => new
                    {
                        x.FirstName,
                        x.LastName,
                        DepartmentName = x.Department.Name,
                        x.Salary
                    })
                    .ToArray();

                using (StreamWriter sw = new StreamWriter("../../../EmployeesFromResearchAndDevelopment.txt"))
                {
                    foreach (var e in employees)
                    {
                        sw.WriteLine($"{e.FirstName} {e.LastName} from {e.DepartmentName} - ${e.Salary:f2}");
                    }
                }
            }
        }
    }
}
