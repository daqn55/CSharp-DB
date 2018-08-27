using System;
using System.Collections.Generic;
using System.Text;

namespace AutoMappingObjects.DTOs
{
    public class ManagerDto
    {
        public ManagerDto()
        {
            this.EmployeesDto = new List<EmployeeDto>();
        }

        public string FirstName { get; set; }

        public string LastName { get; set; }

        public int EmployeesCount => EmployeesDto.Count;

        public ICollection<EmployeeDto> EmployeesDto { get; set; }
    }
}
