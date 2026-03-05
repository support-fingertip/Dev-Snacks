({

    fecthCompany: function(component,event,helper) {
        var action=component.get("c.getCompany");
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                
                var result = response.getReturnValue();
                console.log('Company name result=== '+JSON.stringify(result));
                //if(result.companyNamesMap.length>0){
                    var namesMap = component.get('v.companyNames');
                    console.log('result=== '+result.companyNamesMap);
                    var companyList = [];
                    var companies = result.companyNamesMap;
                    for(var key in companies){
                        companyList.push({value: companies[key], label: key});
                    }
                    component.set('v.companyNames',companyList);
                    console.log('companyList=== ' + JSON.stringify(component.get('v.companyNames')));
                //}
                if(result.defaultCompany){
                    component.set('v.account.CompanyId__c',result.defaultCompany);
                    component.set('v.hasDefaultCompany',true);
                }
            }
        });
        $A.enqueueAction(action);
    },
    
    fecthCustomerType : function(component,event,helper) {
        var action=component.get("c.getCustomerType");
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                var result = response.getReturnValue();
                console.log('Company name result=== '+JSON.stringify(result));
                    var namesMap = component.get('v.customerTypes');
                    console.log('result=== '+result.customerTypeMap);
                    var customerList = [];
                    var companies = result.customerTypeMap;
                    for(var key in companies){
                        customerList.push({value: companies[key], label: key});
                    }
                    component.set('v.customerTypes',customerList);
                    console.log('customerList=== ' + JSON.stringify(component.get('v.customerTypes')));

            }
        });
        $A.enqueueAction(action);
    },
    
    /*getRecordTypes : function(component,event,helper) {
        var action=component.get("c.getRecordTypeValues");
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                var result = response.getReturnValue();
               console.log('Account Record Types== '+JSON.stringify(result));
                var recordTypes = result.contactRecordTypes;
                var recordtypeMap = [];
                //component.set('v.recordTypesMap',result.contactRecordTypes);
                for(var key in recordTypes){
                    recordtypeMap.push({label: recordTypes[key], value: key});
                }
                component.set('v.selectedRecordTypeId',result.defaultRecordTypeId);
                component.set('v.recordtypeMap',recordtypeMap);
                console.log('result.defaultRecordTypeId== '+result.defaultRecordTypeId);
                console.log('recordtypeMap=== '+Json.stringify(recordtypeMap));
                
            }
        });
        $A.enqueueAction(action);	
    },*/

    getWarehouses : function(component,event,helper) {
        var action=component.get("c.getwarehouseList");
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                var databox = response.getReturnValue()
              component.set('v.warehouse',databox.whList);
                component.set('v.listId',databox.listId);
               
            }
        });
        $A.enqueueAction(action);		
    },

    /*getRouteId : function(component,event,helper) {
        var action=component.get("c.getRouteId");
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                var routeId = response.getReturnValue();
                console.log('routeId=== '+routeId);
                component.set('v.routeSearchText',routeId);
            }
        });
        $A.enqueueAction(action);		
    },*/
     createStore : function(component,event,helper) {
         //alert('create store====');
         //var recordTypeId = component.get("v.selectedRecordTypeId");
         //console.log('recordTypeId== '+recordTypeId);
        var action=component.get("c.insertAccount");
          action.setParams({
                'acc' :component.get('v.account'),
            });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                var acc = response.getReturnValue();
                component.set('v.account',acc);
                 component.set('v.currentsetp',"2");
                 if( component.get('v.showUpdate')!=true){
                     component.set('v.showAccount',false);
                    helper.showToast("Store Created Successfully. Please upload Photo","Success");
                     component.set('v.spinner',false);
                }
                if( component.get('v.showUpdate')==true){
                    component.set('v.showUpdate',false);
                     component.set('v.showAccount',false);
                    helper.showToast("Store Updated Successfully. Please upload Photo","Success");
                }
                
                 component.set('v.showUpload',true);
            }else if (response.getState() === "ERROR") {
                        //alert(1);
                        var errors = response.getError();
                        //alert(JSON.stringify(errors));
                        if (errors) {
                            if (errors[0] && errors[0].message) {
                                console.log("Error message: " + 
                                            errors[0].message);
                                helper.showToast(errors[0].message,"Error");
                            }
                        }
                    }
        });
        $A.enqueueAction(action);	
    },
    fecthParentAccount : function(component,event,helper) {
        var action=component.get("c.getAccountList");
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                var pAccount = response.getReturnValue();
                component.set('v.parentAccount',pAccount);
            }
        });
        $A.enqueueAction(action);		
    },
    fecthRoute : function(component,event,helper) {
        var action=component.get("c.getRouteList");
          action.setParams({
                'whId' :component.get('v.account.Warehouse__c')
            });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                var rts = response.getReturnValue();
                component.set('v.Routes',rts);
               
            }
        });
        $A.enqueueAction(action);		
    },
    approvalSubmit: function(component,event,helper) {
        var action=component.get("c.submitapproval");
          action.setParams({
                'storeId' :component.get('v.account.Id')
            });
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
               helper.showToast("Store Submited for Approval","Success");
                var navEvt = $A.get("e.force:navigateToSObject");
   			 navEvt.setParams({
      		"recordId": component.get('v.account.Id'),
      		"slideDevName": "detail"
    });
    navEvt.fire();
            }
        });
        $A.enqueueAction(action);		
    },
     fetchStatePicklist : function(component, event, helper){
        var states =["Andhra Pradesh","Arunachal Pradesh","Assam","Bihar","Chhattisgarh","Delhi","Goa","Gujarat","Haryana","Himachal Pradesh","Jammu and Kashmir","Jharkhand(JH)","Karnataka","Kerala","Ladakh","Lakshadweep","Madhya Pradesh","Maharashtra","Manipur","Meghalaya","Mizoram","Nagaland","Odisha","Puducherry","Punjab","Rajasthan","Sikkim","Tamil Nadu","Telangana","Tripura","Uttar Pradesh","Uttarakhand","West Bengal"];
        component.set('v.StatePicklist',states);
    },
     districtPickList : function(component,event,helper){
        var ArunachalPradesh = ["Anjaw","Siang","Changlang","Dibang Valley","East Kameng","East Siang","Kamle","Kra Daadi","Kurung Kumey","Lepa Rada *","Lohit","Longding","Lower Dibang Valley","Lower Siang","Lower Subansiri","Namsai","Pakke Kessang *","Papum Pare","Shi Yomi *","Tawang","Tirap","Upper Siang","Upper Subansiri","West Kameng","West Siang"];
        var AndhraPradesh = ["Anantapur","Chittoor","East Godavari","Guntur","Kadapa","Krishna","Kurnool","Nellore","Prakasam","Srikakulam","Visakhapatnam","Vizianagaram","West Godavari"];
        var Assam = ["Bajali *","Baksa","Barpeta","Biswanath","Bongaigaon","Cachar","Charaideo","Chirang","Darrang","Dhemaji","Dhubri","Dibrugarh","Dima Hasao","Goalpara","Golaghat","Hailakandi","Hojai","Jorhat","Kamrup","Kamrup Metropolitan","Karbi Anglong","Karimganj","Kokrajhar","Lakhimpur","Majuli","Morigaon","Nagaon","Nalbari","Sivasagar","Sonitpur","South Salmara-Mankachar","Tinsukia","Udalguri","West Karbi Anglong"];
        var Bihar = ["Araria","Arwal","Aurangabad","Banka","Begusarai","Bhagalpur","Bhojpur","Buxar","Darbhanga","East Champaran","Gaya","Gopalganj","Jamui","Jehanabad","Kaimur","Katihar","Khagaria","Kishanganj","Lakhisarai","Madhepura","Madhubani","Munger","Muzaffarpur","Nalanda","Nawada","Patna","Purnia","Rohtas","Saharsa","Samastipur","Saran","Sheikhpura","Sheohar","Sitamarhi","Siwan","Supaul","Vaishali","West Champaran"];    
        var Chhattisgarh = ["Balod","Baloda Bazar","Balrampur Ramanujganj*","Bastar","Bemetara","Bijapur","Bilaspur","Dantewada","Dhamtari","Durg","Gariaband","Gaurela Pendra Marwahi*","Janjgir Champa","Jashpur","Kabirdham","Kanker","Kondagaon","Korba","Koriya","Mahasamund","Mungeli","Narayanpur","Raigarh","Raipur","Rajnandgaon","Sukma","Surajpur","Surguja"];
        var Delhi = ["Central Delhi","East Delhi","New Delhi","North Delhi","North East Delhi","North West Delhi","Shahdara","South Delhi","South East Delhi","South West Delhi","West Delhi"];
        var Goa = ["North Goa","South Goa"]; 
        var GUJARAT = ["Ahmedabad","Amreli","Anand","Aravalli","Banaskantha","Bharuch","Bhavnagar","Botad","Chhota Udaipur","Dahod","Dang","Devbhoomi Dwarka","Gandhinagar","Gir Somnath","Jamnagar","Junagadh","Kheda","Kutch","Mahisagar","Mehsana","Morbi","Narmada","Navsari","Panchmahal","Patan","Porbandar","Rajkot","Sabarkantha","Surat","Surendranagar","Tapi","Vadodara","Valsad"];
        var Haryana = ["Ambala","Bhiwani","Charkhi Dadri","Faridabad","Fatehabad","Gurugram *","Hisar","Jhajjar","Jind","Kaithal","Karnal","Kurukshetra","Mahendragarh","Mewat","Palwal","Panchkula","Panipat","Rewari","Rohtak","Sirsa","Sonipat","Yamunanagar"];    
        var HimachalPradesh = ["Bilaspur-HP","Chamba","Hamirpur","Kangra","Kinnaur","Kullu","Lahaul Spiti","Mandi","Shimla","Sirmaur","Solan","Una"];   
        var JammuandKashmir = ["Anantnag","Bandipora","Baramulla","Budgam","Doda","Ganderbal","Jammu","Kathua","Kishtwar","Kulgam","Kupwara","Poonch","Pulwama","Rajouri","Ramban","Reasi","Samba","Shopian","Srinagar","Udhampur"];    
        var Jharkhand = ["Bokaro","Chatra","Deoghar","Dhanbad","Dumka","East Singhbhum","Garhwa","Giridih","Godda","Gumla","Hazaribagh","Jamtara","Khunti","Koderma","Latehar","Lohardaga","Pakur","Palamu","Ramgarh","Ranchi","Sahebganj","Seraikela Kharsawan","Simdega","West Singhbhum"];
        var KARNATAKA = ["Bagalkot","Bangalore Rural","Bangalore Urban","Belgaum","Bellary","Bidar","Chamarajanagar","Chikkaballapur","Chikkamagaluru","Chitradurga","Dakshina Kannada","Davanagere","Dharwad","Gadag","Gulbarga *","Hassan","Haveri","Kodagu","Kolar","Koppal","Mandya","Mysore","Raichur","Ramanagara","Shimoga","Tumkur","Udupi","Uttara Kannada","Vijayanagara *","Vijayapura *","Yadgir"];    
        var Kerala = ["Alappuzha","Ernakulam","Idukki","Kannur","Kasaragod","Kollam","Kottayam","Kozhikode","Malappuram","Palakkad","Pathanamthitta","Thiruvananthapuram","Thrissur","Wayanad"];
        var Ladakh = ["Kargil","Leh"];
        var Lakshadweep = ["Lakshadweep"];
        var MadhyaPradesh = ["Agar Malwa","Alirajpur","Anuppur","Ashoknagar","Balaghat","Barwani","Betul","Bhind","Bhopal","Burhanpur","Chachaura*","Chhatarpur","Chhindwara","Damoh","Datia","Dewas","Dhar","Dindori","Guna","Gwalior","Harda","Hoshangabad","Indore","Jabalpur","Jhabua","Katni","Khandwa","Khargone","Maihar*","Mandla","Mandsaur","Morena","Nagda*","Narsinghpur","Neemuch","Niwari *","Panna","Raisen","Rajgarh","Ratlam","Rewa","Sagar","Satna","Sehore","Seoni","Shahdol","Shajapur","Sheopur","Shivpuri","Sidhi","Singrauli","Tikamgarh","Ujjain","Umaria","Vidisha"];
        var Maharashtra = ["Ahmednagar","Akola","Amravati","Aurangabad-MH","Beed","Bhandara","Buldhana","Chandrapur","Dhule","Gadchiroli","Gondia","Hingoli","Jalgaon","Jalna","Kolhapur","Latur","Mumbai City","Mumbai Suburban","Nagpur","Nanded","Nandurbar","Nashik","Osmanabad","Palghar","Parbhani","Pune","Raigad","Ratnagiri","Sangli","Satara","Sindhudurg","Solapur","Thane","Wardha","Washim","Yavatmal"];
        var Manipur = ["Bishnupur","Chandel","Churachandpur","Imphal East","Imphal West","Jiribam","Kakching","Kamjong","Kangpokpi","Noney","Pherzawl","Senapati","Tamenglong","Tengnoupal","Thoubal","Ukhrul"];
        var Meghalaya = ["East Garo Hills","East Jaintia Hills","East Khasi Hills","North Garo Hills","Ri Bhoi","South Garo Hills","South West Garo Hills","South West Khasi Hills","West Garo Hills","West Jaintia Hills","West Khasi Hills"];
        var Mizoram = ["Aizawl","Champhai","Hnahthial","Khawzawl","Kolasib","Lawngtlai","Lunglei","Mamit","Saiha","Saitual","Serchhip"];
        var Nagaland = ["Mon","Dimapur","Kiphire","Kohima","Longleng","Mokokchung","Noklak","Peren","Phek","Tuensang","Wokha","Zunheboto"];
        var Odisha = ["Angul","Balangir","Balasore","Bargarh","Bhadrak","Boudh","Cuttack","Debagarh","Dhenkanal","Gajapati","Ganjam","Jagatsinghpur","Jajpur","Jharsuguda","Kalahandi","Kandhamal","Kendrapara","Kendujhar","Khordha *","Koraput","Malkangiri","Mayurbhanj","Nabarangpur","Nayagarh","Nuapada","Puri","Rayagada","Sambalpur","Subarnapur","Sundergarh"];
        var Puducherry = ["Karaikal","Mahe","Puducherry","Yanam"];
        var Punjab = ["Amritsar","Barnala","Bathinda","Faridkot","Fatehgarh Sahib","Fazilka","Firozpur","Gurdaspur","Hoshiarpur","Jalandhar","Kapurthala","Ludhiana","Mansa","Moga","Mohali","Muktsar","Pathankot","Patiala","Rupnagar","Sangrur","Shaheed Bhagat Singh Nagar","Tarn Taran"];
        var Rajasthan = ["Ajmer","Alwar","Banswara","Baran","Barmer","Bharatpur","Bhilwara","Bikaner","Bundi","Chittorgarh","Churu","Dausa","Dholpur","Dungarpur","Sri Ganganagar","Hanumangarh","Jaipur","Jaisalmer","Jalore","Jhalawar","Jhunjhunu","Jodhpur","Karauli","Kota","Nagaur","Pali","Pratapgarh","Rajsamand","Sawai Madhopur","Sikar","Sirohi","Tonk","Udaipur"];
        var Sikkim = ["East Sikkim","North Sikkim","South Sikkim","West Sikkim"];
        var TamilNadu = ["Ariyalur","Chengalpattu *","Chennai","Coimbatore","Cuddalore","Dharmapuri","Dindigul","Erode","Kallakurichi *","Kanchipuram","Kanyakumari","Karur","Krishnagiri","Madurai","Mayiladuthurai*","Nagapattinam","Namakkal","Nilgiris","Perambalur","Pudukkottai","Ramanathapuram","Ranipet*","Salem","Sivaganga","Tenkasi *","Thanjavur","Theni","Thoothukudi","Tiruchirappalli","Tirunelveli","Tirupattur*","Tiruppur","Tiruvallur","Tiruvannamalai","Tiruvarur","Vellore","Viluppuram","Virudhunagar"];
        var Telangana = ["Adilabad","Bhadradri Kothagudem","Hyderabad","Jagtial","Jangaon","Jayashankar Bhupalpally","Jogulamba Gadwal","Kamareddy","Karimnagar","Khammam","Komaram Bheem","Mahabubabad","Mahbubnagar","Mancherial","Medak","Medchal","Mulugu *","Nagarkurnool","Nalgonda","Narayanpet *","Nirmal","Nizamabad","Peddapalli","Rajanna Sircilla","Ranga Reddy","Sangareddy","Siddipet","Suryapet","Vikarabad","Wanaparthy","Warangal Rural","Warangal Urban","Yadadri Bhuvanagiri"];
        var Tripura = ["Dhalai","Gomati","Khowai","North Tripura","Sepahijala","South Tripura","Unakoti","West Tripura"];
        var UttarPradesh = ["Agra","Aligarh","Prayagraj*","Ambedkar Nagar","Amethi *","Amroha *","Auraiya","Azamgarh","Baghpat","Bahraich","Ballia","Balrampur","Banda","Barabanki","Bareilly","Basti","Bhadohi","Bijnor","Budaun","Bulandshahr","Chandauli","Chitrakoot","Deoria","Etah","Etawah","Ayodhya *","Farrukhabad","Fatehpur","Firozabad","Gautam Buddha Nagar","Ghaziabad","Ghazipur","Gonda","Gorakhpur","Hamirpur-UP","Hapur *","Hardoi","Hathras *","Jalaun","Jaunpur","Jhansi","Kannauj","Kanpur Dehat *","Kanpur Nagar","Kasganj *","Kaushambi","Kheri","Kushinagar","Lalitpur","Lucknow","Maharajganj","Mahoba","Mainpuri","Mathura","Mau","Meerut","Mirzapur","Moradabad","Muzaffarnagar","Pilibhit","Pratapgarh-UP","Raebareli","Rampur","Saharanpur","Sambhal *","Sant Kabir Nagar","Shahjahanpur","Shamli *","Shravasti","Siddharthnagar","Sitapur","Sonbhadra","Sultanpur","Unnao","Varanasi"];
        var Uttarakhand = ["Almora","Bageshwar","Chamoli","Champawat","Dehradun","Haridwar","Nainital","Pauri","Pithoragarh","Rudraprayag","Tehri","Udham Singh Nagar","Uttarkashi"];
        var WestBengal = ["Alipurduar","Bankura","Birbhum","Cooch Behar","Dakshin Dinajpur","Darjeeling","Hooghly","Howrah","Jalpaiguri","Jhargram","Kalimpong","Kolkata","Malda","Murshidabad","Nadia","North 24 Parganas","Paschim Bardhaman","Paschim Medinipur","Purba Bardhaman","Purba Medinipur","Purulia","South 24 Parganas","Uttar Dinajpur"];    
        
        var state = component.get('v.account.State__c');
        
        if(state === 'Andhra Pradesh'){
            component.set('v.DistPicklist',AndhraPradesh);
        }else if(state === 'Arunachal Pradesh'){
            component.set('v.DistPicklist',ArunachalPradesh);
        }else if(state === 'Assam'){
            component.set('v.DistPicklist',Assam);
        }else if(state === 'Bihar'){
            component.set('v.DistPicklist',Bihar);
        }else if(state === 'Chhattisgarh'){
            component.set('v.DistPicklist',Chhattisgarh);
        }else if(state === 'Delhi'){
            component.set('v.DistPicklist',Delhi);
        }else if(state === 'Goa'){
            component.set('v.DistPicklist',Goa);
        }else if(state === 'Gujarat'){
            component.set('v.DistPicklist',GUJARAT);
        }else if(state === 'Haryana'){
            component.set('v.DistPicklist',Haryana);
        }else if(state === 'Himachal Pradesh'){
            component.set('v.DistPicklist',HimachalPradesh);
        }else if(state === 'Jammu and Kashmir'){
            component.set('v.DistPicklist',JammuandKashmir);
        }else if(state === 'Jharkhand'){
            component.set('v.DistPicklist',Jharkhand);
        }else if(state === 'Karnataka'){
            component.set('v.DistPicklist',KARNATAKA);
        }else if(state === 'Kerala'){
            component.set('v.DistPicklist',Kerala);
        }else if(state === 'Ladakh'){
            component.set('v.DistPicklist',Ladakh);
        }else if(state === 'Lakshadweep'){
            component.set('v.DistPicklist',Lakshadweep);
        }else if(state === 'Madhya Pradesh'){
            component.set('v.DistPicklist',MadhyaPradesh);
        }else if(state === 'Maharashtra'){
            component.set('v.DistPicklist',Maharashtra);
        }else if(state === 'Manipur'){
            component.set('v.DistPicklist',Manipur);
        }else if(state === 'Meghalaya'){
            component.set('v.DistPicklist',Meghalaya);
        }else if(state === 'Mizoram'){
            component.set('v.DistPicklist',Mizoram);
        }else if(state === 'Nagaland'){
            component.set('v.DistPicklist',Nagaland);
        }else if(state === 'Odisha'){
            component.set('v.DistPicklist',Odisha);
        }else if(state === 'Puducherry'){
            component.set('v.DistPicklist',Puducherry);
        }else if(state === 'Punjab'){
            component.set('v.DistPicklist',Punjab);
        }else if(state === 'Rajasthan'){
            component.set('v.DistPicklist',Rajasthan);
        }else if(state === 'Sikkim'){
            component.set('v.DistPicklist',Sikkim);
        }else if(state === 'Tamil Nadu'){
            component.set('v.DistPicklist',TamilNadu);
        }else if(state === 'Telangana'){
            component.set('v.DistPicklist',Telangana);
        }else if(state === 'Tripura'){
            component.set('v.DistPicklist',Tripura);
        }else if(state === 'Uttar Pradesh'){
            component.set('v.DistPicklist',UttarPradesh);
        }else if(state === 'Uttarakhand'){
            component.set('v.DistPicklist',Uttarakhand);
        }else if(state === 'West Bengal'){
            component.set('v.DistPicklist',WestBengal);
        }
        
    },
      fetchStatePicklist1 : function(component,event,helper) {
       var action=component.get("c.getPickListValuesIntoList");
        action.setCallback(this,function(response){
            if(response.getState() == "SUCCESS"){
                var statePicklist= [];
                var result = response.getReturnValue();
            
                 for(var key in result){
                        statePicklist.push({value: result[key], label: key});
                    }
                    component.set('v.StatePicklist1',statePicklist);
            }
        });
        $A.enqueueAction(action);		
    },
     showToast : function(message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":type,
            "message":  message
        });
        toastEvent.fire();
    },
})