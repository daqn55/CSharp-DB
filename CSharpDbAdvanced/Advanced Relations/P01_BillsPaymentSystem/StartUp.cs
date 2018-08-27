using Microsoft.EntityFrameworkCore;
using P01_BillsPaymentSystem.Data;
using P01_BillsPaymentSystem.Data.Models;
using P01_BillsPaymentSystem.Initializer;
using System;
using System.Linq;

namespace P01_BillsPaymentSystem
{
    public class StartUp
    {
        public static void Main(string[] args)
        {
            using(BillsPaymentSystemContext context = new BillsPaymentSystemContext())
            {
                User user = GetUser(context);
                GetInfo(user);

                decimal billsAmount = decimal.Parse(Console.ReadLine());
                PayBills(user, billsAmount);
            }
        }

        private static void PayBills(User user, decimal amount)
        {
            var totalBankAccountMoney = user.PaymentMethods.Where(x => x.BankAccount != null).Sum(x => x.BankAccount.Balance);
            var totalCreditCardMoney = user.PaymentMethods.Where(x => x.CreditCard != null).Sum(x => x.CreditCard.LimitLeft);

            var totalMoney = totalBankAccountMoney + totalCreditCardMoney;

            if (totalMoney >= amount)
            {
                var bankAccounts = user.PaymentMethods.Where(x => x.BankAccount != null).Select(x => x.BankAccount).OrderBy(x => x.BankAccountId).ToArray();

                foreach (var b in bankAccounts)
                {
                    if (b.Balance >= amount)
                    {
                        b.Withdraw(amount);
                        amount = 0;
                        return;
                    }
                    else
                    {
                        amount -= b.Balance;
                        b.Withdraw(b.Balance);
                    }
                }

                var creditCards = user.PaymentMethods.Where(x => x.CreditCard != null).Select(x => x.CreditCard).OrderBy(x => x.CreditCardId).ToArray();

                foreach (var c in creditCards)
                {
                    if (c.LimitLeft >= amount)
                    {
                        c.Withdraw(amount);
                        amount = 0;
                        return;
                    }
                    else
                    {
                        amount -= c.LimitLeft;
                        c.Withdraw(c.LimitLeft);
                    }
                }
            }
            else
            {
                Console.WriteLine("Insufficient funds!");
            }
        }

        private static void GetInfo(User user)
        {
            Console.WriteLine($"User: {user.FirstName} {user.LastName}");
            Console.WriteLine("Bank Accounts:");

            var bankAccounts = user.PaymentMethods.Where(x => x.BankAccount != null).Select(x => x.BankAccount).ToArray();
            var creditCards = user.PaymentMethods.Where(x => x.CreditCard != null).Select(x => x.CreditCard).ToArray();

            foreach (var b in bankAccounts)
            {
                Console.WriteLine($"-- ID: {b.BankAccountId}");
                Console.WriteLine($"--- Balance: {b.Balance:f2}");
                Console.WriteLine($"--- SWIFT: {b.SwiftCode}");
            }

            Console.WriteLine("Credit Cards:");
            foreach (var c in creditCards)
            {
                Console.WriteLine($"-- ID: {c.CreditCardId}");
                Console.WriteLine($"--- Limit: {c.Limit:f2}");
                Console.WriteLine($"--- Money Owed: {c.MoneyOwed:f2}");
                Console.WriteLine($"--- Limit Left: {c.LimitLeft:f2}");
                Console.WriteLine($"--- Expiration Date: {c.ExpirationDate.Year}/{c.ExpirationDate.Month}");
            }
        }

        private static User GetUser(BillsPaymentSystemContext context)
        {
            int userId = int.Parse(Console.ReadLine());

            User user = null;

            while (true)
            {
                user = context.Users
                            .Where(x => x.UserId == userId)
                            .Include(x => x.PaymentMethods)
                            .ThenInclude(x => x.BankAccount)
                            .Include(x => x.PaymentMethods)
                            .ThenInclude(x => x.CreditCard)
                            .FirstOrDefault();

                if (user == null)
                {
                    Console.WriteLine($"User with id {userId} not found!");
                    userId = int.Parse(Console.ReadLine());
                    continue;
                }

                break;
            }


            return user;
        }
    }
}
