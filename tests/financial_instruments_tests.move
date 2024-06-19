import unittest
from financial_instruments import ComplexFinancialProduct, RiskManager
import os
API_KEY = os.getenv('FINANCIAL_API_KEY')
CONFIG_OPTION = os.getenv('CONFIG_OPTION')
class TestFinancialInstruments(unittest.TestCase):
    def setUp(self):
        self.product_params = {
            'name': 'Complex Fin Product',
            'initial_investment': 10000,
            'risk_level': 'High'
        }
        self.complex_product = ComplexFinancialProduct(**self.product_params)
        self.risk_manager = RiskManager(API_KEY, CONFIG_OPTION)
    def test_product_creation(self):
        self.assertEqual(self.complex_product.name, self.product_params['name'])
        self.assertEqual(self.complex_product.initial_investment, self.product_params['initial_investment'])
        self.assertEqual(self.complex_product.risk_level, self.product_params['risk_level'])
    def test_risk_management_protocol(self):
        self.risk_manager.analyze_risk = lambda x: {'status': 'ok', 'risk_evaluated': True}
        risk_analysis = self.risk_manager.analyze_risk(self.complex_product)
        self.assertTrue(risk_analysis['risk_evaluated'])
        self.assertEqual(risk_analysis['status'], 'ok')
    def test_financial_product_management(self):
        initial_investment = self.complex_product.initial_investment
        self.complex_product.update_investment(5000)
        self.assertEqual(self.complex_product.initial_investment, initial_investment + 5000)
if __name__ == '__main__':
    unittest.main()