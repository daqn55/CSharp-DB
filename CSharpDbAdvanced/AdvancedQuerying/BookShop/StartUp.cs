namespace BookShop
{
    using BookShop.Data;
    using BookShop.Initializer;
    using BookShop.Models;
    using Microsoft.EntityFrameworkCore;
    using System;
    using System.Globalization;
    using System.Linq;
    using System.Text;

    public class StartUp
    {
        public static void Main()
        {
            using (var db = new BookShopContext())
            {
                //---Problem 1
                //string command = Console.ReadLine();
                //string result = GetBooksByAgeRestriction(db, command);
                //Console.WriteLine(result);

                //---Problem 2
                //string result = GetGoldenBooks(db);
                //Console.WriteLine(result);

                //---Problem 3
                //string result = GetBooksByPrice(db);
                //Console.WriteLine(result);

                //---Problem 4
                //int year = int.Parse(Console.ReadLine());
                //string result = GetBooksNotRealeasedIn(db, year);
                //Console.WriteLine(result);

                //---Problem 5
                //string input = Console.ReadLine();
                //string result = GetBooksByCategory(db, input);
                //Console.WriteLine(result);

                ////---Problem 6
                //string date = Console.ReadLine();
                //string result = GetBooksReleasedBefore(db, date);
                //Console.WriteLine(result);

                //---Problem 7
                //string input = Console.ReadLine();
                //var result = GetAuthorNamesEndingIn(db, input);
                //Console.WriteLine(result);

                //---Problem 8
                //string input = Console.ReadLine();
                //var result = GetBookTitlesContaining(db, input);
                //Console.WriteLine(result);

                //---Problem 9
                //string input = Console.ReadLine();
                //var result = GetBooksByAuthor(db, input);
                //Console.WriteLine(result);

                //---Problem 10
                //int lengthCheck = int.Parse(Console.ReadLine());
                //Console.WriteLine(CountBooks(db, lengthCheck));

                //---Problem 11
                //Console.WriteLine(CountCopiesByAuthor(db));

                //---Problem 12
                //Console.WriteLine(GetTotalProfitByCategory(db));

                //---Problem 13
                //Console.WriteLine(GetMostRecentBooks(db));

                //---Problem 14
                //IncreasePrices(db);

                //---Problem 15
                Console.WriteLine($"{RemoveBooks(db)} books were deleted");
            }
        }

        public static int RemoveBooks(BookShopContext context)
        {
            var books = context.Books.Where(x => x.Copies < 4200).ToArray();
            var count = books.Length;

            context.Books.RemoveRange(books);
            context.SaveChanges();

            return count;
        }

        public static void IncreasePrices(BookShopContext context)
        {
            var prices = context.Books
                            .Where(x => x.ReleaseDate.Value.Year < 2010)
                            .ToArray();

            foreach (var p in prices)
            {
                p.Price += 5;
            }

            context.SaveChanges();
        }

        public static string GetMostRecentBooks(BookShopContext context)
        {
            var books = context.Categories
                            .Select(x => new
                            {
                                categoryName = x.Name,
                                books = x.CategoryBooks.OrderByDescending(o => o.Book.ReleaseDate).Take(3).Select(b => new { b.Book.Title, b.Book.ReleaseDate.Value.Year }).ToArray()
                            })
                            .OrderBy(x => x.categoryName)
                            .ToArray();

            var sb = new StringBuilder();

            foreach (var b in books)
            {
                sb.AppendLine($"--{b.categoryName}");
                foreach (var i in b.books)
                {
                    sb.AppendLine($"{i.Title} ({i.Year})");
                }
            }

            return sb.ToString().TrimEnd();
        }

        public static string GetTotalProfitByCategory(BookShopContext context)
        {
            var profits = context.Categories
                            .Select(x => new
                            {
                                category = x.Name,
                                profit = x.CategoryBooks.Sum(s => s.Book.Copies * s.Book.Price)
                            })
                            .OrderByDescending(x => x.profit)
                            .ThenBy(x => x.category)
                            .ToArray();

            var sb = new StringBuilder();

            foreach (var p in profits)
            {
                sb.AppendLine($"{p.category} ${p.profit:f2}");
            }

            return sb.ToString().TrimEnd();
        }

        public static string CountCopiesByAuthor(BookShopContext context)
        {
            var authors = context.Authors
                               .Select(x => new
                               {
                                   fullName = string.Concat(x.FirstName, " ", x.LastName),
                                   copies = x.Books.Sum(c => c.Copies)
                               })
                               .OrderByDescending(x => x.copies)
                               .ToArray();

            var sb = new StringBuilder();

            foreach (var a in authors)
            {
                sb.AppendLine($"{a.fullName} - {a.copies}");
            }

            return sb.ToString().TrimEnd();
        }

        public static int CountBooks(BookShopContext context, int lengthCheck)
        {
            var booksCount = context.Books
                                .Where(x => x.Title.Length > lengthCheck)
                                .Count();

            return booksCount;
        }

        public static string GetBooksByAuthor(BookShopContext context, string input)
        {
            var books = context.Books
                            .Where(x => x.Author.LastName.ToLower().StartsWith(input.ToLower()))
                            .OrderBy(x => x.BookId)
                            .Select(x => new
                            {
                                x.Title,
                                AuthorName = string.Concat(x.Author.FirstName, " ", x.Author.LastName)
                            })
                            .ToArray();

            var sb = new StringBuilder();

            foreach (var b in books)
            {
                sb.AppendLine($"{b.Title} ({b.AuthorName})");
            }

            return sb.ToString().TrimEnd();
        }

        public static string GetBookTitlesContaining(BookShopContext context, string input)
        {
            var books = context.Books
                            .Where(x => x.Title.ToLower().Contains(input.ToLower()))
                            .OrderBy(x => x.Title)
                            .Select(x => x.Title)
                            .ToArray();

            return string.Join(Environment.NewLine, books);
        }

        public static string GetAuthorNamesEndingIn(BookShopContext context, string input)
        {
            var sb = new StringBuilder();

            var books = context.Authors
                            .Where(x => x.FirstName.EndsWith(input))
                            .OrderBy(x => string.Concat(x.FirstName, " ", x.LastName))
                            .Select(x => string.Concat(x.FirstName, " ", x.LastName))
                            .ToArray();

            return string.Join(Environment.NewLine, books);
        }

        public static string GetBooksReleasedBefore(BookShopContext context, string date)
        {
            var sb = new StringBuilder();
            var parsedDate = DateTime.ParseExact(date, "dd-MM-yyyy", CultureInfo.InvariantCulture);

            var books = context.Books
                            .Where(x => x.ReleaseDate.Value < parsedDate)
                            .OrderByDescending(x => x.ReleaseDate)
                            .Select(x => new
                            {
                                x.Title,
                                x.EditionType,
                                x.Price
                            })
                            .ToArray();

            foreach (var b in books)
            {
                sb.AppendLine($"{b.Title} - {b.EditionType} - ${b.Price:f2}");
            }

            return sb.ToString().TrimEnd();
        }

        public static string GetBooksByCategory(BookShopContext context, string input)
        {
            var categories = input.ToLower().Split(" ", StringSplitOptions.RemoveEmptyEntries);

            var books = context.Books
                            .Where(x => x.BookCategories.Any(c => categories.Contains(c.Category.Name.ToLower())))
                            .OrderBy(x => x.Title)
                            .Select(x => x.Title)
                            .ToArray();

            return string.Join(Environment.NewLine, books);
        }

        public static string GetBooksNotRealeasedIn(BookShopContext context, int year)
        {
            var books = context.Books
                            .Where(x => x.ReleaseDate.Value.Year != year)
                            .OrderBy(x => x.BookId)
                            .Select(x => x.Title)
                            .ToArray();

            return string.Join(Environment.NewLine, books);
        }

        public static string GetBooksByPrice(BookShopContext context)
        {
            var books = context.Books
                            .Where(x => x.Price > 40)
                            .OrderByDescending(x => x.Price)
                            .Select(x => $"{x.Title} - ${x.Price:f2}")
                            .ToArray();

            return string.Join(Environment.NewLine, books);
        }

        public static string GetGoldenBooks(BookShopContext context)
        {
            var books = context.Books
                            .Where(x => x.EditionType == EditionType.Gold && x.Copies < 5000)
                            .OrderBy(x => x.BookId)
                            .Select(x => x.Title)
                            .ToArray();

            return string.Join(Environment.NewLine, books);
        }

        public static string GetBooksByAgeRestriction(BookShopContext context, string command)
        {
            var ageRestriction = (AgeRestriction)Enum.Parse(typeof(AgeRestriction), command, true);

            var books = context.Books
                            .Where(x => x.AgeRestriction == ageRestriction)
                            .OrderBy(x => x.Title)
                            .Select(x => x.Title)
                            .ToArray();

            return string.Join(Environment.NewLine, books);
        }
    }
}
