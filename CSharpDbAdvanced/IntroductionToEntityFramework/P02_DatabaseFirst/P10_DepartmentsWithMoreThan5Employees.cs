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
    public class P10_DepartmentsWithMoreThan5Employees
    {
        public static void Run()
        {
            using (SoftUniContext context = new SoftUniContext())
            {
                var employees = context.Departments.Where(x => x.Employees.Count > 5)
                                                        .OrderBy(x => x.Employees.Count)
                                                        .ThenBy(x => x.Name)
                                                        .Select(x => new
                                                        {
                                                            depName = x.Name,
                                                            managerName = x.Manager.FirstName + " " + x.Manager.LastName,
                                                            employeesInDep = x.Employees.Select(e => new
                                                            {
                                                                firstName = e.FirstName,
                                                                lastName = e.LastName,
                                                                jobTitle = e.JobTitle
                                                            })
                                                                .OrderBy(e => e.firstName)
                                                                .ThenBy(e => e.lastName)
                                                                .ToArray()
                                                        })
                                                        .ToArray();

                using (StreamWriter sw = new StreamWriter("../../../DepartmentsWithMoreThan5Employees.txt"))
                {
                    foreach (var e in employees)
                    {
                        sw.WriteLine($"{e.depName} - {e.managerName}");
                        foreach (var p in e.employeesInDep)
                        {
                            sw.WriteLine($"{p.firstName} {p.lastName} - {p.jobTitle}");
                        }
                        sw.WriteLine("----------");
                    }
                }
            }
        }
    }
}
