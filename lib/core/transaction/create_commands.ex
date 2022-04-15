defmodule Devi.Core.Transaction.CreateCommands do
  @moduledoc """
  Provides functions for creating transactions to ensure correct handling of
  account entry
  """

  alias Devi.Core.AccountEntry
  alias Devi.Core.Transaction

  @doc """
  For use when an owner wants to make a contribution of some asset.

  Example - a shareholder buys stock

    iex> owner_account = Devi.Core.Account.new(%{type: :capital, id: :mac})
    ...> cash_account = Devi.Core.Account.new(%{type: :asset, id: :cash})
    ...> Devi.make_contribution(%{capital_account: owner_account, asset_account: cash_account, amount: 30000}, now)

    %Devi.Core.Transaction{
      account_entries: [
        %Devi.Core.AccountEntry{
          account: %Devi.Core.Account{id: :cash, type: :asset},
          amount: 30000,
          inserted_at: now,
          type: :increase
        },
        %Devi.Core.AccountEntry{
          account: %Devi.Core.Account{id: :mac, type: :capital},
          amount: 30000,
          inserted_at: now,
          type: :increase
        }
      ],
      inserted_at: now
    }
  """
  @spec make_contribution(
          %{capital_account: Account.t(), asset_account: Account.t(), amount: pos_integer},
          DateTime.t()
        ) ::
          Transaction.t()
  def make_contribution(
        %{
          capital_account: %{type: :capital} = owner,
          asset_account: %{type: :asset} = asset,
          amount: amount
        },
        %DateTime{} = now
      ) do
    new(
      [
        AccountEntry.new(%{
          account: asset,
          amount: amount,
          type: :increase,
          inserted_at: now
        }),
        AccountEntry.new(%{
          account: owner,
          amount: amount,
          type: :increase,
          inserted_at: now
        })
      ],
      now
    )
  end

  ######
  #
  #
  # Make Purchases
  #
  #
  ###

  @doc """
  For use when there will be a trade of one asset for another 

  Example - purchase office supplies for cash

    iex> cash_account = Devi.Core.Account.new(%{type: :asset, id: :cash})
    ...> land_account = Devi.Core.Account.new(%{type: :asset, id: :land})
    ...> Devi.Core.purchase_with_asset(%{from_account: cash_account, to_account: land_account, amount: 20000}, now)

    %Devi.Core.Transaction{
      account_entries: [
        %Devi.Core.AccountEntry{
          account: %Devi.Core.Account{id: :cash, type: :asset},
          amount: 20000,
          inserted_at: now,
          type: :decrease
        },
        %Devi.Core.AccountEntry{
          account: %Devi.Core.Account{id: :land, type: :asset},
          amount: 20000,
          inserted_at: now,
          type: :increase
        }
      ],
      inserted_at: now
    }
  """
  @spec purchase_with_asset(
          %{from_account: Account.t(), to_account: Account.t(), amount: pos_integer},
          DateTime.t()
        ) ::
          Transaction.t()
  def purchase_with_asset(
        %{from_account: %{type: :asset} = from, to_account: %{type: :asset} = to, amount: amount},
        %DateTime{} = now
      ) do
    new(
      [
        AccountEntry.new(%{
          account: from,
          amount: amount,
          type: :decrease,
          inserted_at: now
        }),
        AccountEntry.new(%{
          account: to,
          amount: amount,
          type: :increase,
          inserted_at: now
        })
      ],
      now
    )
  end

  @doc """
  For use when an asset will be aquired in exchage for a liability

  Example - purchase office supplies on credit

    iex>supplies_account = Devi.Core.Account.new(%{type: :asset, id: :supplies})
    ...>accounts_payable_account = Devi.Core.Account.new(%{type: :liability, id: :accounts_payable})
    ...>Devi.Core.purchase_on_account(%{asset_account: supplies_account, liability_account: accounts_payable_account, amount: 500}, now)

    %Devi.Core.Transaction{
      account_entries: [
        %Devi.Core.AccountEntry{
          account: %Devi.Core.Account{id: :accounts_payable, type: :liability},
          amount: 500,
          inserted_at: now,
          type: :increase
        },
        %Devi.Core.AccountEntry{
          account: %Devi.Core.Account{id: :supplies, type: :asset},
          amount: 500,
          inserted_at: now,
          type: :increase
        }
      ],
      inserted_at: now
    }
  """
  @spec purchase_on_account(
          %{asset_account: Account.t(), liability_account: Account.t(), amount: pos_integer},
          DateTime.t()
        ) ::
          Transaction.t()
  def purchase_on_account(
        %{
          asset_account: %{type: :asset} = asset,
          liability_account: %{type: :liability} = liability,
          amount: amount
        },
        %DateTime{} = now
      ) do
    new(
      [
        AccountEntry.new(%{
          account: liability,
          amount: amount,
          type: :increase,
          inserted_at: now
        }),
        AccountEntry.new(%{
          account: asset,
          amount: amount,
          type: :increase,
          inserted_at: now
        })
      ],
      now
    )
  end

  ######
  #
  #
  # Earn Revenue
  #
  #
  ###

  @doc """
  For use when revenue if earned

  Example - a customer owes an amount of cash for servcies rendered

    iex> service_account = Devi.Core.Account.new(%{type: :revenue, id: :service})
    ...> accounts_receivable_account = Devi.Core.Account.new(%{type: :asset, id: :accounts_receivable})
    ...> Devi.Core.earn_asset_revenue(%{asset_account: accounts_receivable_account, revenue_account: service_account, amount: 3000}, now)

    %Devi.Core.Transaction{
      account_entries: [
        %Devi.Core.AccountEntry{
          account: %Devi.Core.Account{id: :accounts_receivable, type: :asset},
          amount: 3000,
          inserted_at: now,
          type: :increase
        },
        %Devi.Core.AccountEntry{
          account: %Devi.Core.Account{id: :service, type: :revenue},
          amount: 3000,
          inserted_at: now,
          type: :increase
        }
      ],
      inserted_at: now
    }
  """
  @spec earn_asset_revenue(
          %{asset_account: Account.t(), revenue_account: Account.t(), amount: pos_integer},
          DateTime.t()
        ) ::
          Transaction.t()
  def earn_asset_revenue(
        %{
          asset_account: %{type: :asset} = asset,
          revenue_account: %{type: :revenue} = revenue,
          amount: amount
        },
        %DateTime{} = now
      ) do
    new(
      [
        AccountEntry.new(%{
          account: asset,
          amount: amount,
          type: :increase,
          inserted_at: now
        }),
        AccountEntry.new(%{
          account: revenue,
          amount: amount,
          type: :increase,
          inserted_at: now
        })
      ],
      now
    )
  end

  ######
  #
  #
  # Make Payments
  #
  #
  ###

  @doc """
  For use when paying off liabilities

  Example - a customer pays an invoice with cash

    iex> cash_account = Devi.Core.Account.new(%{type: :asset, id: :cash})
    ...> accounts_payable_account = Devi.Core.Account.new(%{type: :liability, id: :accounts_payable})
    ...> Devi.Core.pay_on_account(%{asset_account: cash_account, liability_account: accounts_payable_account, amount: 300}, now)
    
    %Devi.Core.Transaction{
      account_entries: [
        %Devi.Core.AccountEntry{
          account: %Devi.Core.Account{id: :accounts_payable, type: :liability},
          amount: 300,
          inserted_at: now,
          type: :decrease
        },
        %Devi.Core.AccountEntry{
          account: %Devi.Core.Account{id: :cash, type: :asset},
          amount: 300,
          inserted_at: now,
          type: :decrease
        }
      ],
      inserted_at: now
    }
  """
  @spec pay_on_account(
          %{asset_account: Account.t(), liability_account: Account.t(), amount: pos_integer},
          DateTime.t()
        ) ::
          Transaction.t()
  def pay_on_account(
        %{
          asset_account: %{type: :asset} = asset,
          liability_account: %{type: :liability} = liability,
          amount: amount
        },
        %DateTime{} = now
      ) do
    new(
      [
        AccountEntry.new(%{
          account: liability,
          amount: amount,
          type: :decrease,
          inserted_at: now
        }),
        AccountEntry.new(%{
          account: asset,
          amount: amount,
          type: :decrease,
          inserted_at: now
        })
      ],
      now
    )
  end

  @doc """
  For use when paying for an expense

  Example - a cash payment for salary

    iex> cash_account = Devi.Core.Account.new(%{type: :asset, id: :cash})
    ...> salary_account = Devi.Core.Account.new(%{type: :expense, id: :salary})
    ...> Devi.Core.pay_expenses(%{expense_account: salary_account, asset_account: cash_account, amount: 1200}, now)
    
    %Devi.Core.Transaction{
      account_entries: [
        %Devi.Core.AccountEntry{
          account: %Devi.Core.Account{id: :salary, type: :asset},
          amount: 1200,
          inserted_at: now,
          type: :increase
        },
        %Devi.Core.AccountEntry{
          account: %Devi.Core.Account{id: :cash, type: :asset},
          amount: 1200,
          inserted_at: now,
          type: :decrease
        }
      ],
      inserted_at: now
    }
  """
  @spec pay_expenses(
          %{asset_account: Account.t(), expense_account: Account.t(), amount: pos_integer},
          DateTime.t()
        ) ::
          Transaction.t()
  def pay_expenses(
        %{
          asset_account: %{type: :asset} = asset,
          expense_account: %{type: :expense} = expense,
          amount: amount
        },
        %DateTime{} = now
      ) do
    new(
      [
        AccountEntry.new(%{
          account: expense,
          amount: amount,
          type: :increase,
          inserted_at: now
        }),
        AccountEntry.new(%{
          account: asset,
          amount: amount,
          type: :decrease,
          inserted_at: now
        })
      ],
      now
    )
  end

  @doc """
  For use when paying shareholder dividends

  Note - there is no enforced connection between capital accounts and dividend
  accounts but in practice there is probably a correlation between the two

  Example - a divident payment to an owner.

    iex> cash_account = Devi.Core.Account.new(%{type: :asset, id: :cash})
    ...> dividend_account = Devi.Core.Account.new(%{type: :dividend, id: :mac})
    ...> Devi.Core.pay_dividend(%{dividend_account: dividend_account, asset_account: cash_account, amount: 5000}, now)

    %Devi.Core.Transaction{
      account_entries: [
        %Devi.Core.AccountEntry{
          account: %Devi.Core.Account{id: :mac, type: :dividend},
          amount: 5000,
          inserted_at: now,
          type: :increase
        },
        %Devi.Core.AccountEntry{
          account: %Devi.Core.Account{id: :cash, type: :asset},
          amount: 5000,
          inserted_at: now,
          type: :decrease
        }
      ],
      inserted_at: now
    }
  """
  @spec pay_dividend(
          %{asset_account: Account.t(), dividend_account: Account.t(), amount: pos_integer},
          DateTime.t()
        ) ::
          Transaction.t()
  def pay_dividend(
        %{
          asset_account: %{type: :asset} = asset,
          dividend_account: %{type: :dividend} = dividend,
          amount: amount
        },
        %DateTime{} = now
      ) do
    new(
      [
        AccountEntry.new(%{
          account: dividend,
          amount: amount,
          type: :increase,
          inserted_at: now
        }),
        AccountEntry.new(%{
          account: asset,
          amount: amount,
          type: :decrease,
          inserted_at: now
        })
      ],
      now
    )
  end

  # This is here rather than on Transaction to emphasize the need to use the
  #   public interface to crete
  defp new([_ | [_ | _]] = account_entries, now) do
    %Transaction{
      account_entries: account_entries,
      inserted_at: now
    }
  end
end
