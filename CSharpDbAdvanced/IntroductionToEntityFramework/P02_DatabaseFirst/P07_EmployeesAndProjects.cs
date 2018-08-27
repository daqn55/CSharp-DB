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
    public class P07_EmployeesAndProjects
    {
        public static void Run()
        {
            using (SoftUniContext context = new SoftUniContext())
            {
                var employees = context.Employees.Where(x => x.EmployeesProjects.Any(p => p.Project.StartDate.Year >= 2001 && p.Project.StartDate.Year <= 2003))
                                                 .Select(x => new
                                                 {
                                                     employeeName = x.FirstName + " " + x.LastName,
                                                     managerName = x.Manager.FirstName + " " + x.Manager.LastName,
                                                     projects = x.EmployeesProjects.Select(p => new
                                                     {
                                                         projectName = p.Project.Name,
                                                         startDate = p.Project.StartDate,
                                                         endDate = p.Project.EndDate
                                                     }).ToArray()
                                                 })
                                                 .Take(30)
                                                 .ToArray();
                using (StreamWriter sw = new StreamWriter("../../../EmployeesAndProjects.txt"))
                {
                    foreach (var e in employees)
                    {
                        sw.WriteLine($"{e.employeeName} - Manager: {e.managerName}");
                        foreach (var p in e.projects)
                        {
                            var endDate = p.endDate.ToString();
                            if (endDate == "")
                            {
                                endDate = "not finished";
                            }
                            sw.WriteLine($"--{p.projectName} - {p.startDate.ToString("M/d/yyyy h:mm:ss tt", CultureInfo.InvariantCulture)} - {p.endDate?.ToString("M/d/yyyy h:mm:ss tt", CultureInfo.InvariantCulture) ?? "not finished"}");
                        }
                    }
                }
            }
        }
    }
}
