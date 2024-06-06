from typing import Dict, Tuple
import os
import numpy as np
from scipy.stats import norm
import datetime

API_KEY = os.getenv('API_KEY')
SECRET_KEY = os.getenv('SECRET_KEY')

class TradeActionError(Exception):
    """Exception raised for invalid trading actions."""
    pass

class Asset:
    def __init__(self, ticker: str):
        self.ticker = ticker

    def evaluate_risk(self):
        pass

    def execute_trade(self, action: str, amount: int):
        if action.lower() not in ['buy', 'sell']:
            raise TradeActionError(f"{action} is not a valid trade action. Choose 'buy' or 'sell'.")
        self._perform_trade(action, amount)

    def _perform_trade(self, action: str, amount: int):
        try:
            print(f"Executing {action} on {amount} units of {self.ticker}")
        except Exception as e:
            print(f"Trade execution failed for {self.ticker}: {e}")

class OptionsContract(Asset):
    def __init__(self, ticker: str, base_asset: str, expiry_date: str, exercise_price: float):
        super().__init__(ticker)
        self.base_asset = base_asset
        self.expiry_date = expiry_date
        self.exercise_price = exercise;rice

    def evaluate_risk(self, current_price: float, asset_volatility: float, risk_free_interest: float, days_to_expiry: float) -> Dict[str, float]:
        try:
            option_value = self._compute_option_value(current_price, asset_volatility, risk_free_interest, days_to_expiry)
            return {"option_value": option_value}
        except ZeroDivisionError:
            print("Risk evaluation error: Division by zero.")
            return {}
        except ValueError as error:
            print(f"ValueError encountered: {error}")
            return {}

    def _compute_option_value(self, current_price: float, asset_volatility: float, risk_free_interest: float, days_to_expiry: float) -> float:
        try:
            d1, d2 = self._calculate_d1_d2_factors(current_price, asset_volatility, risk_free_interest, days_to_expiry)
            option_value = (current_price * norm.cdf(d1) - self.exercise_price * np.exp(-risk_free_interest * days_to_expiry) * norm.cdf(d2))
            return option_value
        except Exception as error:
            print(f"Error in option value computation: {error}")
            return 0.0 

    def _calculate_d1_d2_factors(self, current_price: float, asset_volatility: float, risk_free_interest: float, days_to_expiry: float) -> Tuple[float, float]:
        try:
            d1 = (np.log(current_price / self.exercise_price) + (risk_free_interest + 0.5 * asset_volatility ** 2) * days_to_expiry) / (asset_volatility * np.sqrt(days_to_expiry))
            d2 = d1 - asset_volatility * np.sqrt(days_to_expiry)
            return d1, d2
        except Exception as error:
            print(f"Error calculating d1 and d2: {error}")
            return 0.0, 0.0 

class Bond(Asset):
    def __init__(self, ticker: str, nominal_value: float, annual_coupon: float, years_to_maturity: int):
        super().__init__(ticker)
        if annual_coupon < 0 or annual_coupon > 1:
            raise ValueError("Coupon rate must be a decimal between 0 and 1.")
        if years_to_maturity < 1:
            raise ValueError("There must be at least one year until maturity.")
        self.nominal_value = nominal_value
        self.annual_coupon = annual_coupon
        self.years_to_maturity = years_to_maturity

    def evaluate_risk(self, trade_price: float) -> Dict[str, float]:
        try:
            yield_to_maturity = self._compute_yield_to_maturity(trade_price)
            return {"yield_to_maturity": yield_to_maturity}
        except ZeroDivisionError:
            print("Error in YTM calculation: Division by zero.")
            return {}
        except ValueError as error:
            print(f"ValueError encountered: {error}")
            return {}

    def _compute_yield_to_maturity(self, trade_price: float) -> float:
        try:
            annual_coupon_payment = self.nominal_value * self.annual_coupon
            ytm = ((annual_coupon_payment + (self.nominal_value - trade_price) / self.years_to_maturity) / ((self.nominal_value + trade_price) / 2))
            return ytm
        except Exception as error:
            print(f"YTM calculation failure: {error}")
            return 0.0 

if __name__ == "__main__":
    try:
        options = OptionsContract('OptionAAPL', 'AAPL', '2023-12-31', 150.00)
        corporate_bond = Bond('BondXYZ', 1000, 0.05, 10)

        options_risk = options.evaluate_risk(100, 0.2, 0.01, 1)
        bond_risk = corporate_bond.evaluate_risk(950)

        options.execute_trade('buy', 10)
        corporate_bond.execute_trade('sell', 5)

        print(options_risk)
        print(bond_risk)
    except Exception as error:
        print(f"An unexpected error occurred: {error}")