using System;
using System.Collections.Generic;
using System.Text;

namespace AutoMappingObjects.DTOs
{
    public class EmployeesOlderThanDto
    {
        public string FirstName { get; set; }

        public string LastName { get; set; }

        public decimal Salary { get; set; }

        public ManagerDto Manager { get; set; }
    }
}
