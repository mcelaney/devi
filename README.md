# Devi

Devi is a double-entry accounting system. It allows projects to leverage a mature
ledger and standard statements and reporting.

This is currently intended as a simple proof of concept for a library that could
be of value to projects such as retail platforms - however we may eventually
mature this in to a package which could be available through hex for your projects.

## Why do we need this?

Most retail platforms leave accouning practices as an afterthought. This works
fine so long as financial transactions remain simple - but eventually a point is
reached where features such as reporting, refunds, or payment splitting cause
extremely complex logic.

A common riddle to illustrate.

Three people split a $30 hotel room evently three ways. The hotel asks an
employee to deliver a refund of $5. The guests tip the employee $2 and then each
receive a dollar. This means that their original payment of $10 each is now $9.
$9 * 3 is $27... plus the $2 tip is $29... so where did the other dollar go?

The riddle illustrates the dangers of mixing accounting logic. The $2 value
only exists on one side of an equation:

25 + 3 + 2 == (9 + 1) + (9 + 1) + (9 + 1)

... so trying to assess it on the incorrect side causes hard-to-understand bugs.
We've seen those kinds of bugs in production on dozens of retail libraries --
with massive amounts of code used to prevent them.

This library looks to remove those kinds of errors using standard accouning
practices.

## Installation

Lint the project with `mix credo --strict`

Run tests with `mix test`

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/devi>.

