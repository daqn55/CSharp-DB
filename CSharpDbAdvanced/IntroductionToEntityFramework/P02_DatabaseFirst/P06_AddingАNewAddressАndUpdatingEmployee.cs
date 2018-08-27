using P02_DatabaseFirst.Data;
using P02_DatabaseFirst.Data.Models;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;

namespace P02_DatabaseFirst
{
    public class P06_AddingАNewAddressАndUpdatingEmployee
    {
        public static void Run()
        {
            using (SoftUniContext context = new SoftUniContext())
            {
                var address = new Address()
                {
                    AddressText = "Vitoshka 15",
                    TownId = 4
                };

                var employee = context.Employees
                    .First(x => x.LastName == "Nakov");

                employee.Address = address;
                context.SaveChanges();

                var employees = context.Employees
                    .OrderByDescending(x => x.AddressId)
                    .Take(10)
                    .Select(x => new
                    {
                        addressText = x.Address.AddressText
                    })
                    .ToArray();

                using (StreamWriter sw = new StreamWriter("../../../AddingАNewAddressАndUpdatingEmployee.txt"))
                {
                    foreach (var e in employees)
                    {
                        sw.WriteLine($"{e.addressText}");
                    }
                }
            }
        }
    }
}
