using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using FastFood.Data;
using FastFood.DataProcessor.Dto.Import;
using FastFood.Models;
using Newtonsoft.Json;
using System.Xml;
using System.Xml.Serialization;
using System.IO;
using System.Globalization;
using FastFood.Models.Enums;

namespace FastFood.DataProcessor
{
	public static class Deserializer
	{
		private const string FailureMessage = "Invalid data format.";
		private const string SuccessMessage = "Record {0} successfully imported.";

		public static string ImportEmployees(FastFoodDbContext context, string jsonString)
		{
            var sb = new StringBuilder();

            var json = JsonConvert.DeserializeObject<EmployeeDto[]>(jsonString);

            var employees = new List<Employee>();
            foreach (var employeeDto in json)
            {
                if (!IsValid(employeeDto))
                {
                    sb.AppendLine(FailureMessage);
                    continue;
                }

                Position position = GetPosition(context, employeeDto.Position);

                var employee = new Employee
                {
                    Name = employeeDto.Name,
                    Age = employeeDto.Age,
                    Position = position
                };

                sb.AppendLine(string.Format(SuccessMessage, employee.Name));
                employees.Add(employee);
            }

            context.Employees.AddRange(employees);
            context.SaveChanges();

            return sb.ToString().TrimEnd();
		}


        public static string ImportItems(FastFoodDbContext context, string jsonString)
		{
            var sb = new StringBuilder();

            var json = JsonConvert.DeserializeObject<ItemDto[]>(jsonString);

            var categories = new List<Category>();
            var items = new List<Item>();

            foreach (var itemDto in json)
            {
                if (!IsValid(itemDto))
                {
                    sb.AppendLine(FailureMessage);
                    continue;
                }

                var item = items.FirstOrDefault(x => x.Name == itemDto.Name);
                if (item != null)
                {
                    sb.AppendLine(FailureMessage);
                    continue;
                }

                var category = categories.FirstOrDefault(x => x.Name == itemDto.Category);
                if (category == null)
                {
                    category = new Category
                    {
                        Name = itemDto.Category
                    };
                }

                item = new Item
                {
                    Name = itemDto.Name,
                    Price = itemDto.Price,
                    Category = category
                };

                categories.Add(category);
                items.Add(item);

                sb.AppendLine(string.Format(SuccessMessage, itemDto.Name));
            }

            context.Categories.AddRange(categories);
            context.SaveChanges();

            context.Items.AddRange(items);
            context.SaveChanges();

            return sb.ToString().TrimEnd();
		}

		public static string ImportOrders(FastFoodDbContext context, string xmlString)
		{
            var sb = new StringBuilder();

            var xml = new XmlSerializer(typeof(OrderDto[]), new XmlRootAttribute("Orders"));
            var deserializerOrders = (OrderDto[])xml.Deserialize(new StringReader(xmlString));

            var orderItems = new List<OrderItem>();
            var orders = new List<Order>();


            foreach (var orderDto in deserializerOrders)
            {
                var isValidItem = true;

                if (!IsValid(orderDto))
                {
                    sb.AppendLine(FailureMessage);
                    continue;
                }

                foreach (var i in orderDto.OrderItems)
                {
                    if (!IsValid(i))
                    {
                        isValidItem = false;
                        break;
                    }
                }

                if (!isValidItem)
                {
                    sb.AppendLine(FailureMessage);
                    continue;
                }

                bool itemInContextExist = CheckItem(context, orderDto.OrderItems);

                if (!itemInContextExist)
                {
                    sb.AppendLine(FailureMessage);
                    continue;
                }

                var employee = context.Employees.FirstOrDefault(x => x.Name == orderDto.Employee);

                if (employee == null)
                {
                    sb.AppendLine(FailureMessage);
                    continue;
                }

                var date = DateTime.ParseExact(orderDto.DateTime, "dd/MM/yyyy HH:mm", CultureInfo.InvariantCulture);
                var type = Enum.Parse<OrderType>(orderDto.Type);

                var order = new Order
                {
                    Customer = orderDto.Customer,
                    DateTime = date,
                    Type = type,
                    Employee = employee
                };

                orders.Add(order);

                foreach (var i in orderDto.OrderItems)
                {
                    var item = context.Items.FirstOrDefault(x => x.Name == i.Name);

                    var orderItem = new OrderItem
                    {
                        Order = order,
                        Item = item,
                        Quantity = i.Quantity
                    };

                    orderItems.Add(orderItem);
                    
                }

                sb.AppendLine($"Order for {orderDto.Customer} on {orderDto.DateTime} added");
            }
            context.Orders.AddRange(orders);
            context.SaveChanges();

            context.OrderItems.AddRange(orderItems);
            context.SaveChanges();

            return sb.ToString().TrimEnd();
        }

        private static bool CheckItem(FastFoodDbContext context, ItemOrderDto[] orderItems)
        {
            foreach (var i in orderItems)
            {
                var existItem = context.Items.Any(x => x.Name == i.Name);

                if (!existItem)
                {
                    return false;
                }
            }

            return true;
        }

        private static Position GetPosition(FastFoodDbContext context, string positionName)
        {
            var position = context.Positions.FirstOrDefault(x => x.Name == positionName);

            if (position == null)
            {
                position = new Position
                {
                    Name = positionName
                };

                context.Positions.Add(position);
                context.SaveChanges();
            }

            return position;
        }

        private static bool IsValid(object obj)
        {
            var validationContext = new ValidationContext(obj);
            var validationResult = new List<ValidationResult>();

            return Validator.TryValidateObject(obj, validationContext, validationResult, true);
        }
	}
}