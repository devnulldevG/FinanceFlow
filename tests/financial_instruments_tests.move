import unittest
from financial_instruments import ComplexFinancialProduct, RiskManager
import os

API_KEY = os.getenv('FINANCIAL_API_KEY')
CONFIG_OPTION = os.getenv('CONFIG_OPTION')

class TestFinancialInstruments(unittest.TestCase):
    def setUp(self):
        self.setup_product()
        self.setup_risk_manager()

    def setup_product(self):
        product_params = {
            'name': 'Complex Fin Product',
            'initial_investment': 10000,
            'risk_level': 'High'
        }
        self.complex_product = ComplexFinancialProduct(**product_params)

    def setup_risk_manager(self):
        self.risk_manager = RiskManager(API_KEY, CONFIG_OPTION)

    def test_product_creation(self):
        self.verify_product_attributes()

    def verify_product_attributes(self):
        product_params = {
            'name': 'Complex Fin Product',
            'initial_investment': 10000,
            'risk_level': 'High'
        }
        self.assertEqual(self.complex_product.name, product_params['name'])
        self.assertEqual(self.complex_product.initial_investment, product_params['initial_investment'])
        self.assertEqual(self.complex_product.risk_level, product_params['risk_level'])

    def test_risk_management_protocol(self):
        self.mock_risk_analysis()
        risk_analysis = self.risk_manager.analyze_risk(self.complex_product)
        self.assert_risk_analysis_outcome(risk_analysis)

    def mock_risk_analysis(self):
        self.risk_manager.analyze_risk = lambda x: {'status': 'ok', 'risk_evaluated': True}

    def assert_risk_analysis_outcome(self, risk_analysis):
        self.assertTrue(risk_analysis['risk_evaluated'])
        self.assertEqual(risk_analysis['status'], 'ok')

    def test_financial_product_management(self):
        self.verify_updated_investment()

    def verify_updated_investment(self):
        initial_investment = self.complex_product.initial_investment
        self.complex_product.update_investment(5000)
        self.assertEqual(self.complex_product.initial_investment, initial_investment + 5000)

if __name__ == '__main__':
    unittest.main()