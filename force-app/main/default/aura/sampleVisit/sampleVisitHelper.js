({  
    
    data:{'visits':[],
          'dailyLog': {}, 
          'accounts':[],'currentvisit':{},
          'summaryCount':{'visitCount' : 0,'InProgress' : 0,'plannedVisits' : 0, 'completedVisits' : 0,'Postponed':0},
          'offlineRecords':0
         },
    scrollStopPropagation: function(e) {
        e.stopPropagation();
    },
    doInitHelper:function(component,event,helper){
        
        if(!window.navigator.onLine){
            component.set('v.data',  JSON.parse( localStorage.getItem("data") ) );
            var data = JSON.parse( localStorage.getItem("data"));
             var offlinedata = 0;
            if(data == null || data == '' || data == 'null'){
                offlinedata = 0;
            }else{
                offlinedata=data.offlineRecords;
                if(offlinedata != null || offlinedata !=0 ||offlinedata !='' ){
                    component.set('v.offlineCount',offlinedata);
                    component.set('v.onlineStatus',false);
                }
            }
        }else{
            var data = JSON.parse( localStorage.getItem("data"));
            var offlinedata = 0;
            if(data == null || data == '' || data == 'null'){
                offlinedata = 0;
            }else{
                offlinedata=data.offlineRecords;
            }
            if(offlinedata == null || offlinedata ==0 ||offlinedata =='' ){
                
                var action=component.get("c.getDailyLog");
                action.setCallback(this,function(response){
                    if(response.getState() == "SUCCESS"){ 
                        helper.data.dailyLog  = response.getReturnValue();
                        var action=component.get("c.getAccounts");    
                        action.setCallback(this,function(response){
                            if(response.getState()=="SUCCESS"){ 
                                helper.data.accounts = response.getReturnValue(); 
                                var action=component.get("c.getTodaysVisits");
                                action.setCallback(this,function(response){
                                    if(response.getState() == "SUCCESS"){ 
                                        helper.data.visits = response.getReturnValue();
                                        component.set('v.data',  helper.data)
                                        window.localStorage.setItem("data",   JSON.stringify(helper.data)   );
                                        helper.visitsCount(component,event,helper);
                                    }
                                });
                                $A.enqueueAction(action); 
                                
                            }
                        });
                        $A.enqueueAction(action);
                        
                    }
                });
                $A.enqueueAction(action);
                
            }else{
                helper.offlinedata(component, event, helper);
            }
            
        } 	
    },
    
    visitsCount : function(component,event,helper){
        var data = component.get('v.data.visits');
        const propOwn = Object.getOwnPropertyNames(data);
        component.set('v.data.summaryCount.visitCount',propOwn.length-1);
       
        var count =0;
        var count1 =0;
        var count2 =0;
        var count3 =0;
        for(var i=0;i<data.length; i++){ 
            if(data[i].Status__c ==='Planned' ){
                count = count+1;
            }else if(data[i].Status__c ==='Completed'){
                count1 = count1+1;
            }else if(data[i].Status__c ==='In Progress'){
                count2 = count2+1;
            }else if(data[i].Status__c ==='Missed'){
                count3 = count3+1;
            } 
        }
        if(count2 !=0){
            for(var i=0;i<data.length; i++){ 
                if(data[i].Status__c ==='In Progress' ){
                    component.set('v.data.currentvisit',data[i]);
                    break;
                }}
        }else if(count !=0){
            for(var i=0;i<data.length; i++){ 
                if(data[i].Status__c ==='Planned' ){
                    component.set('v.data.currentvisit',data[i]);
                    break;
                }}
        }else{
            component.set('v.data.currentvisit','');
        }
        var ph= component.get('v.data.currentvisit.Account1__r.Phone');
        var tel = 'tel:'+ph;
        component.set('v.Phone',tel);
        component.set('v.data.summaryCount.plannedVisits',count);
        component.set('v.data.summaryCount.completedVisits',count1);
        component.set('v.data.summaryCount.InProgress',count2);
        component.set('v.data.summaryCount.Postponed',count3);
    },
    
    dataHandler : function(component,event,helper) {  
        
        var data =   JSON.parse( JSON.stringify(component.get('v.data') ) );
        localStorage.setItem("data",   JSON.stringify(data)); 
        
        if(window.navigator.onLine ){  
            
            var action=component.get("c.upsertAccounts");
            action.setParams({'accountList':  data.accounts  })
            action.setCallback(this,function(response){ 
                if(response.getState() == "SUCCESS"){ 
                    helper.data.accounts  = response.getReturnValue();
                    component.set('v.data',helper.data);
                    localStorage.setItem("data",   JSON.stringify(helper.data)   ); 
                }
            });
            $A.enqueueAction(action); 
            
            var action1 =component.get("c.upsertVisits");
            action1.setParams({'visitList':  JSON.stringify(data.visits)  })
            action1.setCallback(this,function(response){
                if(response.getState() == "SUCCESS"){ 
                     helper.data.visits = response.getReturnValue();
                  	 component.set('v.data',  helper.data)
                     localStorage.setItem("data",   JSON.stringify(helper.data)   );
                    
                }
            });
            $A.enqueueAction(action1);
            
            var action2 =component.get("c.upsertDailyLog");
            action2.setParams({'dailylog':  data.dailyLog  })
            action2.setCallback(this,function(response){
                if(response.getState() == "SUCCESS"){ 
                    helper.data.dailylog = response.getReturnValue();
                     helper.data.offlineRecords = 0;
                    component.set('v.data', helper.data)
                   localStorage.setItem("data",   JSON.stringify(helper.data)   );
                    component.set('v.spinner',false);
                    helper.visitsCount(component,event,helper);
                    component.set('v.onlineStatus',true);
                    component.set('v.offlineCount',0); 
                    helper.showToast("Sync finished successfully","Success");
                    
                    //localStorage.setItem("data", null);
                    //helper.doInitHelper(component, event, helper);
                }
            });
            $A.enqueueAction(action2);
        } 
    },
    offlinedata : function(component,event,helper) {  
        
        var data = JSON.parse( localStorage.getItem("data"));
        //JSON.parse( localStorage.getItem("data")
        if(window.navigator.onLine ){  
            var action=component.get("c.upsertAccounts");
            
            action.setParams({'accountList':  data.accounts  })
            action.setCallback(this,function(response){ 
                if(response.getState() == "SUCCESS"){ 
                     helper.data.accounts  = response.getReturnValue();
                    component.set('v.data',helper.data);
                    localStorage.setItem("data",   JSON.stringify(helper.data)   ); 
                }
            });
            $A.enqueueAction(action); 
            
            var action1 =component.get("c.upsertVisits");
            
            action1.setParams({'visitList':  JSON.stringify(data.visits)  })
            action1.setCallback(this,function(response){
                if(response.getState() == "SUCCESS"){ 
                    helper.data.visits = response.getReturnValue();
                  	 component.set('v.data',  helper.data)
                     localStorage.setItem("data",   JSON.stringify(helper.data)   );
                }
            });
            $A.enqueueAction(action1);
            
            var action2 =component.get("c.upsertDailyLog");
            
            action2.setParams({'dailylog':  data.dailyLog  })
            action2.setCallback(this,function(response){
                if(response.getState() == "SUCCESS"){  
                    helper.data.dailylog = response.getReturnValue();
                     helper.data.offlineRecords = 0;
                    component.set('v.data', helper.data)
                    localStorage.setItem("data",   JSON.stringify(helper.data)   );
                    component.set('v.onlineStatus',true);
                    component.set('v.offlineCount',0); 
                    helper.visitsCount(component,event,helper);
                    
                    // helper.showToast("Offline data sync finished successfully","Success");
                    //helper.doInitHelper(component, event, helper);
                }
            });
            $A.enqueueAction(action2);
            
            
        } 
    },
    storeHandler : function(component,event,helper) {  
        
        var data =   JSON.parse( JSON.stringify(component.get('v.data') ) );
        if(!window.navigator.onLine){
            localStorage.setItem("data",   JSON.stringify(data));
            helper.showToast("Store created successfully","Success");
        }else{  
            var action=component.get("c.upsertAccounts");
            action.setParams({'accountList':  data.accounts  })
            action.setCallback(this,function(response){ 
                if(response.getState() == "SUCCESS"){ 
                    helper.data.accounts  = response.getReturnValue();
                    component.set('v.data',helper.data);
                    localStorage.setItem("data",   JSON.stringify(helper.data)   ); 
                    helper.showToast("Store created successfully","Success");
                    
                }
            });
            $A.enqueueAction(action); 
        }
    },
    checkHandler : function(component,event,helper) {
        
        var data =   JSON.parse( JSON.stringify(component.get('v.data') ) );
        if(!window.navigator.onLine){
            localStorage.setItem("data",   JSON.stringify(data)); 
             window.scroll(0,1800);
            component.set('v.spinner',false);
            if(component.get('v.checkout')==='true'){
                helper.showToast("Successfully checked out","Success");
                helper.updateCurrentVisit(component,event,helper);
                component.set('v.checkout','false');
            }else if(component.get('v.checkin')==='true'){
                helper.updateCurrentVisit(component,event,helper);
                helper.showToast("Successfully checked in","Success");
                component.set('v.checkin','false');
            }else if(component.get('v.newvisit')==='true'){
                helper.showToast("Visit Created Successfully","Success");
                helper.updateCurrentVisit(component,event,helper);
                component.set('v.newvisit','false');  
            }else{
                helper.showToast("You missed this visit ","info");
            }
        }else{
            
            var action1 =component.get("c.upsertVisits");
            action1.setParams({'visitList':  JSON.stringify(data.visits)  });
             
            action1.setCallback(this,function(response){
                   helper.data.visits = response.getReturnValue();
                     if(response.getState() == "SUCCESS"){
                         
                      component.set('v.data',  helper.data)
                     localStorage.setItem("data",   JSON.stringify(helper.data)   );
                    console.log('get',response.getState());
                          window.scroll(0,1800);
                	component.set('v.spinner',false);
                    if(component.get('v.checkout')==='true'){
                        helper.showToast("Successfully checked out","Success");
                        helper.updateCurrentVisit(component,event,helper);
                        component.set('v.checkout','false');
                    }else if(component.get('v.checkin')==='true'){
                        helper.showToast("Successfully checked in","Success");
                       
                        component.set('v.checkin','false');
                    }else if(component.get('v.newvisit')==='true'){
                        helper.showToast("Visit Created Successfully","Success");
                        helper.updateCurrentVisit(component,event,helper);
                        component.set('v.newvisit','false');  
                    }else{
                        helper.showToast("You missed this visit ","info");
                        
                    }
                    component.set('v.showall',false);
                } 
            });
            $A.enqueueAction(action1);
            
            
        }
        
    },
    dailylogHandler : function(component,event,helper) {  
        var data = JSON.parse( JSON.stringify(component.get('v.data') ) );
        if(!window.navigator.onLine ){
            localStorage.setItem("data",   JSON.stringify(data)); 
             component.set('v.spinner',false);
            if(component.get('v.data.dailyLog.Clock_Out__c')==null){
                helper.showToast("Day started ","Success");
            }else{
                helper.showToast("Day ended","Success");
            }
        }else{
            component.set('v.showall',true);
            var action2 = component.get("c.upsertDailyLog");
            action2.setParams({'dailylog':  data.dailyLog  });
            action2.setCallback(this,function(response){
                if(response.getState() == "SUCCESS"){
                    component.set('v.spinner',false);
                     helper.data.dailylog = response.getReturnValue();
                    component.set('v.data', helper.data);
                    localStorage.setItem("data",   JSON.stringify(helper.data)   );
                     if(component.get('v.data.dailyLog.Clock_Out__c')==null){
                        helper.showToast("Day started ","Success");
                    }else{
                        helper.showToast("Day ended","Success");
                    }
                    /*if(data.dailylog.Id !=null || data.dailylog.Id !=''){
                         component.set('v.data.dailyLog.Id',data.dailylog.Id);
                    }
                   alert(component.get('v.data.dailyLog.Id'));*/
                }
            });
            $A.enqueueAction(action2);
        } 
    }, 
    updateCurrentVisit : function(component,event,helper){
        
        if(component.get('v.data.currentvisit.Status__c')==='Completed' || component.get('v.data.currentvisit')==''){
            
            var data = component.get('v.data.visits');
            for(var i=0;i<data.length; i++){ 
                if(data[i].Status__c ==='Planned' ){
                    component.set('v.data.currentvisit',data[i]);
                    break;
                }}
        }
        
    },
    
    catchError : function(error,helper) {
        
        switch(error.code)
        {
            case error.TIMEOUT:
                helper.showToast("The request to get user location has aborted as it has taken too long.");
                break;
            case error.POSITION_UNAVAILABLE:
                helper.showToast("Location information is not available.");
                break;
            case error.PERMISSION_DENIED:
                helper.showToast("Permission to share location information has been denied!");
                break;
            default:
                helper.showToast("An unknown error occurred.");
        }
    },
    
    fetchStatePicklist : function(component, event, helper){
        var states =["Andhra Pradesh","Arunachal Pradesh","Assam","Bihar","Chhattisgarh","Delhi","Goa","Gujarat","Haryana","Himachal Pradesh","Jammu and Kashmir","Jharkhand(JH)","Karnataka","Kerala","Ladakh","Lakshadweep","Madhya Pradesh","Maharashtra","Manipur","Meghalaya","Mizoram","Nagaland","Odisha","Puducherry","Punjab","Rajasthan","Sikkim","Tamil Nadu","Telangana","Tripura","Uttar Pradesh","Uttarakhand","West Bengal"];
        component.set('v.StatePicklist',states);
    },
    checkOnline : function(component, event, helper){
        
        if(!window.navigator.onLine ){
            var count = component.get('v.offlineCount');
            component.set('v.offlineCount',count+1);
            component.set('v.onlineStatus',false);
            helper.data.offlineRecords =count+1;
            component.set('v.data',  helper.data);
            window.localStorage.setItem("data",  JSON.stringify(helper.data));
            
        }
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
    showToast : function(message,type) {
        var toastEvent = $A.get("e.force:showToast");
        toastEvent.setParams({
            "type":type,
            "message":  message
        });
        toastEvent.fire();
    },
     distance:function(lon1, lat1, lon2, lat2) {
        var R = 6371; // Radius of the earth in km
        var dLat = (lat2 - lat1) * Math.PI / 180;  // deg2rad below
        var dLon = (lon2 - lon1) * Math.PI / 180;
        var a = 
            0.5 - Math.cos(dLat)/2 + 
            Math.cos(lat1 * Math.PI / 180) * Math.cos(lat2 * Math.PI / 180) * 
            (1 - Math.cos(dLon))/2;
         return R * 2 * Math.asin(Math.sqrt(a));
        /*const φ1 = lat1 * Math.PI/180, φ2 = lat2 * Math.PI/180, Δλ = (lon2-lon1) * Math.PI/180, R = 6371e3;
					const d = Math.acos( Math.sin(φ1)*Math.sin(φ2) + Math.cos(φ1)*Math.cos(φ2) * Math.cos(Δλ) ) * R;
                   */
        
        
    },
     sendToVF : function(component, helper) {
        //Prepare message in the format required in VF page
        
        var message = {
            "loadGoogleMap" : true,
            "mapData": component.get('v.mapData'), 
            "mapOptions": component.get('v.mapOptions'),  
            'mapOptionsCenter': component.get('v.mapOptionsCenter')
        } ;
        
        //Send message to VF
        helper.sendMessage(component, helper, message);
    },
    sendMessage: function(component, helper, message){
        //Send message to VF
        message.origin = window.location.hostname;
        if(component.find("vfFrame")){
            var vfWindow = component.find("vfFrame").getElement().contentWindow;
            var obj = JSON.parse(JSON.stringify(message));
            console.log('LC ',obj,component.get("v.vfHost"));
            vfWindow.postMessage(obj, component.get("v.vfHost"));
        }
        
    },
   
})