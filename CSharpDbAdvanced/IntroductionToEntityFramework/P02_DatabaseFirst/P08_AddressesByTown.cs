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
    public class P08_AddressesByTown
    {
        public static void Run()
        {
            using (SoftUniContext context = new SoftUniContext())
            {
                var employees = context.Addresses
                                       .Select(x => new
                                       {
                                           address = x.AddressText,
                                           town = x.Town.Name,
                                           employeeCount = x.Employees.Count
                                       })
                                       .OrderByDescending(x => x.employeeCount)
                                       .ThenBy(x => x.town)
                                       .ThenBy(x => x.address)
                                       .Take(10)
                                       .ToArray();

                using (StreamWriter sw = new StreamWriter("../../../AddressesByTown.txt"))
                {
                    foreach (var e in employees)
                    {
                        sw.WriteLine($"{e.address}, {e.town} - {e.employeeCount} employees");
                    }
                }
            }
        }
    }
}
