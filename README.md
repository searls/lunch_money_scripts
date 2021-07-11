# Lunch Money Scripts

## Install

You'll need a working Ruby environment on your machine (I use
[rbenv](https://github.com/rbenv/rbenv) to manage mine). From there:

```
$ bundle
$ ./script/group_refunded_transactions
```

You'll be asked for your lunch money access token, which you can create in the
[developer tab](https://my.lunchmoney.app/developers) of your account settings.

## Group Refunded Transactions

In [Lunch Money](https://lunchmoney.app), if you have two transactions with a
merchant and one is for $45.13 and the other is -$45.13, they will display
separately and—especially if they span multiple months—it won't be clear that
the transaction was refunded and shouldn't _really_ count as an expense. It's
just noise in your transaction history.

What this script does is look through your transactions and find these
offsetting charges, then create a [transaction
group](https://lunchmoney.app/features/transactions) whenever the merchant and
transaction amounts are an exact match. This will effectively zero-out the
transaction from your history.

To run the script, just execute this from the command line:

```
$ ./script/group_refunded_transactions
```

It will ask for your Lunch Money Access Token (and then save it in your keychain
for subsequent runs), as well as what date you want to start from.

The script can also be run non-interactively with command line options like this:

```
$ ./script/group_refunded_transactions --access-token abcdef1234 --start-date 2020-01-01 --confirm
```

