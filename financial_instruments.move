from typing import Dict, Tuple, List
import os
import numpy as np
import pandas as pd
from scipy.stats import norm
import datetime

API_KEY = os.getenv('API_KEY')
SECRET_KEY = os.getenv('SECRET_KEY')

class InvalidTradeActionError(Exception):
    """Raised when an invalid trade action is detected."""
    pass

class FinancialInstrument:
    def __init__(self, symbol: str):
        self.symbol = symbol

    def assess_risk(self):
        pass

    def trade(self):
        pass

class Derivative(FinancialInstrument):
    def __init__(self, symbol: str, underlying_asset: str, maturity_date: str, strike_price: float):
        super().__init__(symbol)
        self.underlying_asset = underlying_asset
        self.maturity_date = maturity_date
        self.strike_price = strike_price

    def assess_risk(self, spot_price: float, volatility: float, risk_free_rate: float, time_to_maturity: float) -> Dict[str, float]:
        try:
            d1 = (np.log(spot_price / self.strike_price) + (risk_free_rate + 0.5 * volatility ** 2) * time_to_maturity) / (volatility * np.sqrt(time_to_maturity))
            d2 = d1 - volatility * np.sqrt(time_to_maturity)
            call_option_price = (spot_price * norm.cdf(d1) - self.strike_price * np.exp(-risk_free_rate * time_to_maturity) * norm.cdf(d2))
            return {"call_option_price": call_option_price}
        except ZeroDivisionError:
            print("Error: Division by zero encountered in risk assessment calculations.")
            return {}
        except ValueError as e:
            print(f"Value error: {e}")
            return {}

    def trade(self, action: str, quantity: int):
        if action.lower() not in ['buy', 'sell']:
            raise InvalidTradeActionError(f"{action} is not a valid trading action. Use 'buy' or 'sell'.")
        print(f"Executing {action} on {quantity} units of {self.symbol}")

class Bond(FinancialInstrument):
    def __init__(self, symbol: str, face_value: float, coupon_rate: float, maturity_years: int):
        super().__init__(symbol)
        if coupon_rate < 0 or coupon_rate > 1:
            raise ValueError("Coupon rate must be between 0 and 1.")
        if maturity_years < 1:
            raise ValueError("Maturity years must be at least 1.")
        self.face_value = face_value
        self.coupon_rate = coupon_rate
        self.maturity_years = maturity_years

    def assess_risk(self, market_price: float) -> Dict[str, float]:
        try:
            coupon = self.face_value * self.coupon_rate
            ytm = ((coupon + (self.face_value - market_price) / self.maturity_years) / ((self.face_value + market_price) / 2))
            return {"yield_to_maturity": ytm}
        except ZeroDivisionError:
            print("Error: Division by zero encountered in YTM calculations.")
            return {}
        except ValueError as e:
            print(f"Value error: {e}")
            return {}

    def trade(self, action: str, quantity: int):
        if action.lower() not in ['buy', 'sell']:
            raise InvalidTradeActionError(f"{action} is not a valid trading action. Use 'buy' or 'sell'.")
        print(f"Executing {action} on {quantity} units of {self.symbol}")

if __name__ == "__main__":
    try:
        derivative = Derivative('Deriv1', 'AAPL', '2023-12-31', 150.00)
        bond = Bond('Bond1', 1000, 0.05, 10)

        derivative_risk = derivative.assess_risk(100, 0.2, 0.01, 1)
        bond_risk = bond.assess_risk(950)

        derivative.trade('buy', 10)
        bond.trade('sell', 5)

        print(derivative_risk)
        print(bond_risk)
    except Exception as e:
        print(f"An error occurred: {e}")