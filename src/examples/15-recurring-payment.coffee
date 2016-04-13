###
  Example 15 - How to create an on-demand recurring payment.
###
mollie = require("./mollie");
fs     = require("fs");

class example
	constructor: (request, response) ->
		mollie.customers.all((customers) =>
			###
				Retrieve the last created customer for this example.
				If no customers are created yet, run example 11.
			###
			customer = customers[0];

			###
			  Generate a unique order id for this example. It is important to include this unique attribute
			  in the redirectUrl (below) so a proper return page can be shown to the customer.
			###
			orderId = new Date().getTime()

			###
				Customer Payment creation parameters:
				See: https://www.mollie.com/en/docs/reference/customers/create-payment
			###
			mollie.customers_payments.withParent(customer).create({
					amount: 10.00,
					description: "An on-demand recurring payment",
					# Flag this payment as a recurring payment.
					recurringType: Mollie.API.Object.Payment.RECURRINGTYPE_FIRST
				}, (payment) =>
					if (payment.error)
						console.error(payment.error);
						return response.end();

					###
					  In this example we store the order with its payment status in a database.
					###
					@databaseWrite(orderId, payment.status);

					###
					  Send the customer off to complete the payment.
					###
					response.writeHead(200, {'Content-Type': "text/html; charset=utf-8"});
					response.write("<p>Your payment status is '#{_.escape(payment.status)}'.</p>");
					response.end();
			);
		);

	###
	  NOTE: This example uses a text file as a database. Please use a real database like MySQL in production code.
	###
	databaseWrite: (orderId, paymentStatus) ->
		orderId = parseInt(orderId);
		fs.writeFile(__dirname + "/orders/order-#{orderId}.txt", paymentStatus);

module.exports = example