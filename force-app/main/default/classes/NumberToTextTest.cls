@IsTest
public class NumberToTextTest {

    @IsTest
    static void testSingleDigit() {
        String result = NumberToText.getNumberWord(5);
        System.assert(result.contains('Five'));
    }

    @IsTest
    static void testDoubleDigit() {
        String result = NumberToText.getNumberWord(15);
        System.assert(result.contains('Fifteen'));
    }

    @IsTest
    static void testTens() {
        String result = NumberToText.getNumberWord(40);
        System.assert(result.contains('Forty'));
    }

    @IsTest
    static void testHundreds() {
        String result = NumberToText.getNumberWord(123);
        System.assert(result.contains('One'));
        System.assert(result.contains('Hundred'));
    }

    @IsTest
    static void testThousands() {
        String result = NumberToText.getNumberWord(1234);
        System.assert(result.contains('Thousand'));
    }

    @IsTest
    static void testMillions() {
        String result = NumberToText.getNumberWord(1234567);
        System.assert(result.contains('Million'));
    }

    @IsTest
    static void testControllerMethod() {
        ApexPages.StandardController sc =
            new ApexPages.StandardController(new Account(Name = 'Test'));
        NumberToText nt = new NumberToText(sc);
        nt.inputNum = 99;
        nt.convertinword();
        System.assert(nt.inttext.contains('Ninety'));
    }
}