defmodule Devi.CoreFixtures do
  alias Devi.Core.Account
  alias Devi.Core.AccountEntry

  #####
  # Account
  ##
  def asset_account_fixture(id \\ "any") do
    Account.new(%{type: :asset, id: id})
  end

  def capital_account_fixture(id \\ "any") do
    Account.new(%{type: :capital, id: id})
  end

  def dividend_account_fixture(id \\ "any") do
    Account.new(%{type: :dividend, id: id})
  end

  def expense_account_fixture(id \\ "any") do
    Account.new(%{type: :expense, id: id})
  end

  def liability_account_fixture(id \\ "any") do
    Account.new(%{type: :liability, id: id})
  end

  def revenue_account_fixture(id \\ "any") do
    Account.new(%{type: :revenue, id: id})
  end

  def account_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{type: :asset, id: :cash})
  end

  def account_functions do
    [
      &asset_account_fixture/1,
      &capital_account_fixture/1,
      &dividend_account_fixture/1,
      &expense_account_fixture/1,
      &liability_account_fixture/1,
      &revenue_account_fixture/1
    ]
  end

  #####
  # Account Entry
  ##

  @types ~w[increase decrease]a

  def account_entry_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      account: Enum.random(account_functions()).(:random),
      amount: :rand.uniform(30_000),
      type: Enum.random(@types),
      inserted_at: Faker.DateTime.backward(90)
    })
  end

  def account_entry_fixture(attrs \\ %{}) do
    struct(AccountEntry, account_entry_attributes(attrs))
  end
end
