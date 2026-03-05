public class NumberToText{    
  
    public integer inputNum  {get;set;}
       public string inttext{get;set;} 
    
    public NumberToText(ApexPages.StandardController controller){
        
    }

     public void convertinword(){        
        inttext=getNumberWord(inputNum);        
    } 
    public static string getNumberWord(integer num){        
        String alphaNumber = '';         
        String numericNumber = string.valueof(num);        
        List<string> numericNumbers = new list <string>();     
        for(integer i=numericNumber.length(); i>0; i-=3){             
            Integer n=0;             
            If(I>3){                 
                n = i-3;          
            }             
            String substring = Numericnumber.substring(n,i);             
            If(substring.length()==2){                 
                Substring = '0'+substring;                 
            }else if(substring.length()==1){                
                Substring = '00'+ substring;                 
            }             
            System.debug('substring '+substring);             
            Numericnumbers.add(substring);            
            If(I<3){break;}             
        }   
        
        for(integer I=0;I<numericnumbers.size();I++){      
            String ngroup = numericnumbers.get(I);             
            String ones = ngroup.substring(2,3);        
            String tens = ngroup.substring(1,2);         
            String hundreds = ngroup.substring(0,1);       
            If(I != 0){                
                If(I == 1){alphanumber = 'Thousand ' + alphanumber;}                 
                Else if(I == 2){alphanumber = 'Million ' + alphanumber;}              
            }     
            If(tens == '1' && ones != '0'){          
                If(ones =='1'){alphanumber = 'Eleven' + alphanumber;}          
                else if(ones == '2'){alphanumber = 'Twelve '+alphanumber;}                 
                else if(ones == '3'){alphanumber = 'Thirteen '+alphanumber;}                 
                else if(ones == '4'){alphanumber = 'Fourteen ' + alphanumber;}                 
                else if(ones == '5'){alphanumber = 'Fifteen ' + alphanumber;}                
                else if(ones == '6'){alphanumber = 'Sixteen ' + alphanumber;}            
                else if(ones == '7'){alphanumber = 'Seventeen ' + alphanumber;}                 
                else if(ones == '8'){alphanumber = 'Eighteen ' + alphanumber;}                
                else if(ones == '9'){alphanumber = 'Nineteen ' + alphanumber;}                 
            }else if(tens == '1' && ones == '0'){            
                Alphanumber = 'Ten ' + alphanumber;           
            }else if(ones != '0'){                 
                String o = underTen(ones);                 
                Alphanumber = o +' '+ alphanumber;                 
            }             
            If(tens != '0' && tens != '1'){                
                If(tens == '2'){alphanumber = 'Twenty ' + alphanumber;}                 
                else if(tens =='3'){alphanumber = 'Thirty ' + alphanumber;}                
                else if(tens == '4'){alphanumber = 'Forty ' + alphanumber;}                 
                else if(tens =='5'){alphanumber = 'Fifty ' +alphanumber;}                 
                else if(tens == '6'){alphanumber = 'Sixty ' + alphanumber;}                
                else if(tens == '7'){alphanumber = 'Seventy ' + alphanumber;}             
                else if(tens == '8'){alphanumber = 'Eighty ' + alphanumber;}                 
                else if(tens == '9'){alphanumber = 'Ninety ' + alphanumber;}                 
            }       
            If(hundreds != '0'){          
                String h = underten(hundreds);              
                alphanumber = h+' Hundred ' + alphanumber;           
            }             
        }         
        alphanumber.capitalize();      
        return alphanumber;   
    }   
    
    public static string underTen(string num){         
        If(num =='1'){num = 'One';}         
        else if(num == '2'){num = 'Two';}         
        else if(num == '3'){num = 'Three';}        
        else if(num == '4'){num = 'Four';}         
        else if(num == '5'){num = 'Five';}         
        else if(num == '6'){num = 'Six';}        
        else if(num == '7'){num = 'Seven';}         
        else if(num == '8'){num = 'Eight';}        
        else if(num == '9'){num = 'Nine';}         
        return num;       
    }    
 }