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
    public class P09_Employee147
    {
        public static void Run()
        {
            using (SoftUniContext context = new SoftUniContext())
            {
                var employees = context.Employees.Where(x => x.EmployeeId == 147)
                                                    .Select(x => new
                                                    {
                                                        empName = x.FirstName + " " + x.LastName,
                                                        jobTitle = x.JobTitle,
                                                        projects = x.EmployeesProjects.Select(p => new
                                                        {
                                                            projectName = p.Project.Name
                                                        })
                                                            .OrderBy(o => o.projectName)
                                                            .ToArray()
                                                    })
                                                    .ToArray();

                using (StreamWriter sw = new StreamWriter("../../../Employee147.txt"))
                {
                    foreach (var e in employees)
                    {
                        sw.WriteLine($"{e.empName} - {e.jobTitle}");
                        foreach (var p in e.projects)
                        {
                            sw.WriteLine(p.projectName);
                        }
                    }
                }
            }
        }
    }
}
