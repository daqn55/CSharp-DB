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
    public class P11_FindLatest10Projects
    {
        public static void Run()
        {
            using (SoftUniContext context = new SoftUniContext())
            {
                var projects = context.Projects.OrderByDescending(x => x.StartDate)
                                                .Take(10)
                                                .Select(x => new
                                                {
                                                    name = x.Name,
                                                    description = x.Description,
                                                    startDate = x.StartDate.ToString("M/d/yyyy h:mm:ss tt")
                                                })
                                                .OrderBy(x => x.name)
                                                .ToArray();

                using (StreamWriter sw = new StreamWriter("../../../FindLatest10Projects.txt"))
                {
                    foreach (var p in projects)
                    {
                        sw.WriteLine(p.name);
                        sw.WriteLine(p.description);
                        sw.WriteLine(p.startDate);
                    }
                }
            }
        }
    }
}
