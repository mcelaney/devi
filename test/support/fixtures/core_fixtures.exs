defmodule Devi.CoreFixtures do
  alias Devi.Core.AccountEntry

  def asset_account_id(account \\ :cash) do
    {:asset, account}
  end

  def capital_account_id(account \\ :mac) do
    {:capital, account}
  end

  def dividend_account_id(account \\ :mac) do
    {:dividend, account}
  end

  def expense_account_id(account \\ :rent) do
    {:expense, account}
  end

  def liability_account_id(account \\ :accounts_payable) do
    {:liability, account}
  end

  def revenue_account_id(account \\ :service) do
    {:revenue, account}
  end

  def account_functions do
    [
      &asset_account_id/1,
      &capital_account_id/1,
      &dividend_account_id/1,
      &expense_account_id/1,
      &liability_account_id/1,
      &revenue_account_id/1
    ]
  end

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
