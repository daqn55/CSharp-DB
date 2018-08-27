using System;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml;
using System.Xml.Serialization;
using FastFood.Data;
using FastFood.DataProcessor.Dto.Export;
using FastFood.Models.Enums;
using Newtonsoft.Json;

namespace FastFood.DataProcessor
{
	public class Serializer
	{
		public static string ExportOrdersByEmployee(FastFoodDbContext context, string employeeName, string orderType)
		{
            var orderTypeAsEnum = Enum.Parse<OrderType>(orderType);

            var employee = context.Employees.Where(x => x.Name == employeeName)
                                            .ToArray()
                                            .Select(x => new
                                            {
                                                Name = x.Name,
                                                Orders = x.Orders.Where(o => o.Type == orderTypeAsEnum)
                                                        .Select(c => new
                                                        {
                                                            Customer = c.Customer,
                                                            Items = c.OrderItems.Select(i => new
                                                            {
                                                                Name = i.Item.Name,
                                                                Price = i.Item.Price,
                                                                Quantity = i.Quantity
                                                            })
                                                            .ToArray(),
                                                            TotalPrice = c.TotalPrice
                                                        })
                                                        .OrderByDescending(d => d.TotalPrice)
                                                        .ThenByDescending(f => f.Items.Length)
                                                        .ToArray(),
                                                TotalMade = x.Orders.Where(o => o.Type == orderTypeAsEnum)
                                                                    .Sum(s => s.TotalPrice)
                                            })
                                            .FirstOrDefault();

            var json = JsonConvert.SerializeObject(employee, Newtonsoft.Json.Formatting.Indented);

            return json;
		}

		public static string ExportCategoryStatistics(FastFoodDbContext context, string categoriesString)
		{
            var categoriesToGet = categoriesString.Split(',');

            var categories = context.Categories.Where(x => categoriesToGet.Any(c => c == x.Name))
                                               .Select(x => new CategoryDto
                                               {
                                                   Name = x.Name,
                                                   MostPopilarItemDto = x.Items.Select(i => new MostPopilarItemDto
                                                   {
                                                       Name = i.Name,
                                                       TotalMade = i.OrderItems.Sum(o => o.Item.Price * o.Quantity),
                                                       TimesSold = i.OrderItems.Sum(o => o.Quantity)
                                                   })
                                                   .OrderByDescending(o => o.TotalMade)
                                                   .FirstOrDefault()
                                               })
                                               .OrderByDescending(x => x.MostPopilarItemDto.TotalMade)
                                               .ThenByDescending(x => x.MostPopilarItemDto.TimesSold)
                                               .ToArray();
            var sb = new StringBuilder();

            var xmlNameSpaces = new XmlSerializerNamespaces(new[] { XmlQualifiedName.Empty });
            var xml = new XmlSerializer(typeof(CategoryDto[]), new XmlRootAttribute("Categories"));
            xml.Serialize(new StringWriter(sb), categories, xmlNameSpaces);

            return sb.ToString();
		}
	}
}