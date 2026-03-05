@isTest
public class NumberTOWordConvertorTest {
    @isTest
    public static void getNumberTOWordConversion_Test(){
        decimal num = 234;

        NumberTOWordConvertor nc = new NumberTOWordConvertor();
        NumberTOWordConvertor nc1 = new NumberTOWordConvertor(null);
        nc.getNumberTOWordConvertion(num);
        nc.getDayOfMonthSuffix(1);
        nc.getDayOfMonthSuffix(2);
        nc.getDayOfMonthSuffix(12);
        nc.getDayOfMonthSuffix(null);
        nc.getDayOfMonthSuffix(3);
        
    }
}