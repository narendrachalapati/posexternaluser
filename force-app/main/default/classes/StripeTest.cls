@IsTest
public class StripeTest {
	@IsTest
    static void zeroDecimalCurrencies_containsAllZeroDecimalCurrenciesOfStripe() {
        Set<String> currencies = new Set<String>();
        currencies.add('MGA');
        currencies.add('BIF');
        currencies.add('CLP');
        currencies.add('DJF');
        currencies.add('GNF');
        currencies.add('KMF');
        currencies.add('KRW');
        currencies.add('RWF');
        currencies.add('VND');
        currencies.add('VUV');
        currencies.add('XAF');
        currencies.add('XOF');
        currencies.add('XPF');

        System.assertEquals(currencies, Stripe.zeroDecimalCurrencies);
    }
    
    @IsTest
    static void testCardsResponseOfStripe() {
        Stripe.CardsResponse sampleResponse = new Stripe.CardsResponse();
        List<Stripe.Card> cardsList = new List<Stripe.Card>();
        Stripe.Card card = new Stripe.Card();
    }
}