function same_country(runConfig, iteration, params){
  return sameText(runConfig.country, params.country);
}

function smoke_test(runConfig, iteration, params){
  return !runConfig.smoke || params.smoke;
}

function iterationFilters(){
  return [
            smoke_test,
            iteration_more_than_zero
          ];
}