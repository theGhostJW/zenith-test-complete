//USEUNIT StringUtils
//USEUNIT SysUtils
//USEUNIT XmlTemplateLoaderUtils
//USEUNIT DateTimeUtils
//USEUNIT XmlTemplateLoaderUtils
//USEUNIT EndPointLauncherUtils

function loadXmlTemplateEndPoint() {
  var data = demoDefaultProperties();
  data = convertAccountFields(data);
  toTemp(data);
  
  var xmlTemplate = testDataString('ExampleTemplate.xml');
  var transformers = {
                  batch: loadTemplate,
                  accounts: accountsTransformer
                 };
  var result = loadXmlTemplate(xmlTemplate, transformers, data);
  toTempString(result, 'batch.xml');
}

function propsObjectFromTemplateEndPoint(){
  toTempString(propsObjectFromTemplate(ACCOUNT_XML()));
}

function boolToYN(bool){
  return bool ? 'Y': 'N';
}

function dateTimeToReadableString(dt){
 GetVarType(dt) === 7 && hasValue(dt) ? DateTimeUtils.dateTimeToReadableString(dt) : dt;
}

function convertAccountFields(props){
  var TRANSFORMERS = {
                        extractDateTime: dateTimeToReadableString,
                        correctionFlag: boolToYN,
                        statusDate: dateTimeToReadableString,
                        openDate: dateTimeToReadableString,
                        closedDate: dateTimeToReadableString,
                        startDate: dateTimeToReadableString,
                        deceased: boolToYN,
                        startDate: dateTimeToReadableString,
                        ceaseDate: dateTimeToReadableString,
                        birthDate: dateTimeToReadableString,
                        period: dateTimeToReadableString
                      };
                  
  
  function transform(val, key){
    var transformer = TRANSFORMERS[key];
    return hasValue(transformer) ? transformer(val) : val;
  }
  
  function transformRecursive(propsObj){
    return mapObjectRecursive(propsObj, transform);
  }
  
  var result = transformRecursive(props);
  result.accounts = _.map(forceArray(result.accounts), transformRecursive);
  
  return result;
}

function accountsTransformer(xmlTemplate, accountsObj){
  var arrAccounts = forceArray(accountsObj);
  
  var accountTemplate = templateParts(xmlTemplate, 'account').section;
  var sectionToRemove = isUndefined(accountsObj.unformattedAddress) 
                                            ? 'unformattedAddress' 
                                            : 'formattedAddress';
                                            
  accountTemplate = removeSection(accountTemplate, sectionToRemove);
   
  function transformAccount(accountObj){
    var flattened = flattenObj(accountObj)
    return loadTemplate(accountTemplate, flattened);
  }
  
  var allAccounts = _.map(arrAccounts, transformAccount)
  return allAccounts.join();
}


function SIGNTORY_ID_NZ(){
  return '000690000065';
}

function demoDefaultProperties(){

  return  {
              batch: {
                batchId: createGuidTruncated(20),
                extractDateTime: now(),
                providerReference: createGuidTruncated(20),
                notificationEmail: 'test@rrrr.com',
                version: 2.02,
                mode: 'T',
                batchType: 'I',
                providerName: createGuidTruncated(20),
                industryType: 'F',
                signatoryId: createGuidTruncated(20),
                signatorySubId: createGuidTruncated(20),
                contactName: createGuidTruncated(20),
                contactEmail: 'mainContactEmail@myServer.com',
                contactPhone: '98288888'
              },
              accounts: {
                            recordId: 1,
                            correctionFlag: false,
                            accountNumber: createGuidTruncated(20),
                            accountSubId: 'ACCS14082015',
                            status: 'A',
                            statusDate: today(),
                            creditPurpose: 'R',
                            accountHolderCount: 1,
                            accountType: 'AL',
                            openDate: datePlus(today(), -(20*30)),
                            closedDate: '',
                            paymentType: 'P',
                            creditType: 'F',
                            termOfLoan: 640,
                            loanPaymentMethod: 'C',
                            unlimitedCredit: false,
                            termType: 'M',
                            securedCredit: 'S',
                            paymentFrequency: 'M',
                            maximumAmountOfCreditAvailable: 100000,
                            
                            creditLimit: 300000,
                            accountName: createGuidTruncated(20),
                            customerCount: 1,
                            customer: {
                              customerId: 244324,
                              startDate: datePlus(today(), -(20*30)),
                              formattedName: {
                                  formattedNameType: 'P',
                                  family: createGuidTruncated(20),
                                  first: createGuidTruncated(20),
                                  middle: createGuidTruncated(20),
                                  title: 'Mr'
                                },
                                relationship: "1",
                                seriousCreditInfringement: false,
                                birthDate: "2070-01-01",
                                deceased: 'N',
                                driversLicence: '',
                                driversLicenceVersion: '',
                                gender: 'M',
                                employerName: 'Test Emp',
                                previousEmployerName: "Fidel's Fish and Chippery",
                                occupation: 'Revolutionary',
                                /*
                                unformattedAddress: {
                                  unformattedAddressType: 'C',
                                  unformattedAddress: '1 Watson Street Akaroa 7520'
                                },
                                */
                                unformattedAddressType: undefined,
                                unformattedAddress: undefined,
                                formattedAddress: {
                                 formattedAddressType: 'C',
                                 property: undefined,
                                 unitNumber: '',
                                 streetNumber:  _.random(1, 100),
                                 streetName: createGuidTruncated(20),
                                 streetType: "Street",
                                 town: createGuidTruncated(20),
                                 suburbTown: createGuidTruncated(20),
                                 state: '',
                                 postcode: 3625,
                                 country: "NZ"
                                }
                            },
                            payment: {
                              period: '2016-09-01',
                              paymentStatus: 'X'
                            }
                        }
          };
}

  

function convertToSimpleTemplateEndPoint() {
  var template = convertToSimpleTemplate(ACCOUNT_XML());
  toTempString(template);
}

function ACCOUNT_XML(){
  return bigString(function(){
                               /*
                                <?xml version="1.0" encoding="utf-8"?>
                                <CRAReportBatch xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
                                  <Batch>
                                    <BatchID></BatchID>
                                    <ExtractDate></ExtractDate>
                                    <ExtractTime></ExtractTime>
                                    <ProviderReference></ProviderReference>
                                    <NotificationEmail></NotificationEmail>
                                    <Version></Version>
                                    <Mode></Mode>
                                    <BatchType></BatchType>
                                    <NameOfTheProvider></NameOfTheProvider>
                                    <IndustryType></IndustryType>
                                    <SignatoryID></SignatoryID>
                                    <SignatorySubID></SignatorySubID>
                                    <MainContactName></MainContactName>
                                    <MainContactEmail></MainContactEmail>
                                    <MainContactPhone></MainContactPhone>
                                    <OptionalContactName></OptionalContactName>
                                    <OptionalContactEmail></OptionalContactEmail>
                                    <OptionalContactPhone></OptionalContactPhone>
                                  </Batch>
                                  <Accounts>
                                    <Account>
                                      <AccountHeader>
                                        <RecordID></RecordID>
                                        <CorrectionFlag></CorrectionFlag>
                                        <AccountID>
                                          <AccountNumber></AccountNumber>
                                          <AccountSubID></AccountSubID>
                                        </AccountID>
                                        <Status></Status>
                                        <StatusDate></StatusDate>
                                        <CreditPurpose></CreditPurpose>
                                        <TypeOfAccount></TypeOfAccount>
                                      </AccountHeader>
                                      <AccountDetail>
                                        <OpenDate></OpenDate>
                                        <ClosedDate></ClosedDate>
                                        <PaymentType></PaymentType>
                                        <CreditType></CreditType>
                                        <SecuredCredit></SecuredCredit>
                                        <TermOfLoan></TermOfLoan>
                                        <PaymentFrequency></PaymentFrequency>
                                        <CreditLimit></CreditLimit>
                                        <AccountName></AccountName>
                                      </AccountDetail>
                                      <CustomerCount></CustomerCount>
                                      <Customer>
                                        <CustomerID></CustomerID>
                                        <StartDate></StartDate>
                                        <CeaseDate />
                                        <CustomerDetail>
                                          <FormattedName>
                                            <FormattedNameType></FormattedNameType>
                                            <Family></Family>
                                            <First></First>
                                            <Middle></Middle>
                                            <Title></Title>
                                          </FormattedName>
                                          <Relationship></Relationship>
                                          <BirthDate></BirthDate>
                                          <Gender></Gender>
                                          <Deceased></Deceased>
                                          <DriversLicence>
                                          <DriversLicenceNumber></DriversLicenceNumber>
                                          <DriversLicenceVersion></DriversLicenceVersion>
                                          </DriversLicence>
                                          <EmployerName></EmployerName>
                                          <PreviousEmployerName></PreviousEmployerName>
                                          <Occupation></Occupation>
                                          <FormattedAddress>
                                            <FormattedAddressType></FormattedAddressType>
                                			      <Property></Property>			
                                			      <UnitNumber></UnitNumber>
                                            <StreetNumber></StreetNumber>
                                            <StreetName></StreetName>
                                            <StreetType></StreetType>
                                            <Town></Town>
                                			      <Suburb></Suburb>
                                            <State></State>
                                            <Postcode></Postcode>
                                			      <Country></Country>
                                          </FormattedAddress>
                                		      <UnformattedAddress>
                                            <UnformattedAddressType></UnformattedAddressType>
                                            <UnformattedAddress></UnformattedAddress>
                                          </UnformattedAddress>
                                        </CustomerDetail>
                                      </Customer>
                                      <Payment>
                                        <Period></Period>
                                        <PaymentStatus></PaymentStatus>
                                      </Payment>
                                    </Account>
                                  </Accounts>
                                </CRAReportBatch> 
                               */
                            }); 
}
