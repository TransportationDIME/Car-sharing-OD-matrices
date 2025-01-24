/*********************************************
 * OPL 12.10.0.0 Model
 * Author: Summair Anis
 * Creation Date: 1 Apr 2021 at 11:55:06
 *********************************************/

 int nz = ...; // number of zones
 int nv = ...; // number of vehicles
 int nt = ...; // number of time slots
 int dum = ...; //check for actual number of vehicles in each zone
 
  
 
 range zones = 1..nz; // zones counter
 range vehicles = 1..nv; // vehicles counter
 range times = 1..nt; //time slot counter
 range d = 1..dum; //veh counter for vehicle check
 
 
 int num_veh[zones]= ...; // maximum number of vehicles in each depot
 float CAI_PT[times][zones] = ...; // CAI provided by public transport in zone
 float acc[zones] = ...; // access parameter for each CS Depot
 float ve[d] = ...; 
 float Delta[times][zones] = ...; 
 
 
 float gamma1 = ...; // cost for the operation and maintenance of depots 
 float gamma2 = ...; // // generic parameter for implementation cost 
 //float gamma3 = ...; // average cost of buying/maintain a vehicle
 float delta = ...;
 float alpha = ...;
 float B_CAI = ...;   // maximum budget for CAI (organization, management)

 float dr[times][zones]=...; //demand rate
 float CAI_max [times]=...;
 
  
 dvar float+ value; //budget utilized
 //dvar float+ CAI_CS[times][zones]; // CAI provided by CS per zone
 dvar float+ CAI_tot[times][zones]; // total CAI per zone
 
 //dvar float+ CAI[zones]; // minimum CAI provided per zone
 //dvar int+ G[zones]; // number of depots activated in each zone
 
 float nb_TW[1..nt*nz*dum] = ...;
 float esp_TW[m in 1..nt, p in 1..nz,s in 1..dum] = nb_TW[s+dum*(p-1)+nz*dum*(m-1)];

execute {
   writeln(esp_TW);
};
float nb_OW[1..nt*nz*dum] = ...;
 float esp_OW[m in 1..nt, p in 1..nz,s in 1..dum] = nb_OW[s+dum*(p-1)+nz*dum*(m-1)];

execute {
   writeln(esp_OW);
};


 /*  
  tuple ZS 
  {
    key int zone;
    key int depots;
  };  
   
{ZS} ZS_range = {<z,dept> | z in zones, dept in depots: acc[z][dept]>=0};

*/
 dvar int+ T_OW[times][zones]; // target value of the number of vehicles per zone 
 dvar int+ T_TW[times][zones];					  
 dvar int tot_veh[times]; // total numeber of used vehicles per time period
 
 dvar boolean x[times][vehicles][zones]; // equal to 1 if vehicle v is in zone z
 dvar boolean y[vehicles][zones];
 dvar boolean g[times][zones];
 dvar boolean h[zones]; // equal to 1 if vehicle CS is in subzone s of zone z
 //dvar boolean g[ZS_range]; // equal to 1 if the CS depot is selected
 dvar float+ CAI_CS[times][zones]; // depots CAI in each time period
 dvar float+ fact_OW[times][zones];
 dvar float+ fact_TW[times][zones]; //calculated actual probability value based on actual vehicles in each zone
 dvar float+ J;
 dvar float+ conn_OW[times][zones];
 dvar float+ conn_TW[times][zones];
 dvar float+ JJ;
 float penalty[times][zones]=...;
 dvar float+ beta[times][zones];
 float sp = ...;
 float ww = ...;
 dvar float+ dep[zones];
 dvar float+ veh[vehicles];
 dvar float+ pp[times][zones];
 dvar float+ cai_c;
   
 maximize JJ;   // (7)
 
 subject to
 {
  JJ == (sum(z in zones) ((5 *(((0.01+ ((CAI_max[1]-CAI_PT[1][z])/CAI_max[1]))^sp)*CAI_tot[1][z]-sum(v in vehicles)((penalty[1][z]^alpha)*x[1][v][z])) +  2 * (((0.01+ ((CAI_max[2]-CAI_PT[2][z])/CAI_max[2]))^sp)*CAI_tot[2][z]-sum(v in vehicles)((penalty[2][z]^alpha)*x[2][v][z])))/7))/nz;
  //JJ == (sum(z in zones) ((5 *(CAI_tot[1][z]-sum(v in vehicles)((penalty[1][z]^alpha)*x[1][v][z])) +  2 * (CAI_tot[2][z]-sum(v in vehicles)((penalty[2][z]^alpha)*x[2][v][z])))/7))/nz;
  //JJ == (sum(z in zones) ((5 *(((0.01+ ((CAI_max[1]-CAI_PT[1][z])/CAI_max[1]))^sp)*CAI_tot[1][z]+sum(v in vehicles)(maxl(0, alpha/delta*(delta-Delta[1][z]))*x[1][v][z])) +  2 * (((0.01+ ((CAI_max[2]-CAI_PT[2][z])/CAI_max[2]))^sp)*CAI_tot[2][z]+sum(v in vehicles)(maxl(0, alpha/delta*(delta-Delta[2][z]))*x[2][v][z])))/7))/nz;
  cai_c==sum(z in zones, t in times)CAI_tot[t][z];
  //JJ == sum(z in zones) (((17*((((CAI_max[1]-CAI_PT[1][z])/CAI_max[1])^sp)*CAI_tot[1][z])) + (4*((((CAI_max[2]-CAI_PT[2][z])/CAI_max[2])^sp)*CAI_tot[2][z])))/21);
  /*
 
  forall (t in times, z in zones)
    {
      CAI_tot[t][z] == CAI_PT[t][z] + CAI_CS[t][z]-sum(v in vehicles) x[t][v][z];
    }
   forall (t in times, z in zones:Delta[t][z]>delta)
    {
      CAI_tot[t][z] == CAI_PT[t][z] + CAI_CS[t][z]-((Delta[t][z]-delta)^alpha)*sum(v in vehicles) x[t][v][z];
      //penalty[t][z]==((Delta[t][z]-delta)^alpha);
    }
   */ 
  forall (t in times, z in zones)
    {
      T_TW[t][z] == sum(v in vehicles) y[v][z];
      T_OW[t][z] == sum(v in vehicles) x[t][v][z];
      conn_OW[t][z] == dr[t][z] * fact_OW[t][z];
      conn_TW[t][z] == dr[t][z] * fact_TW[t][z];
      CAI_CS[t][z] == conn_OW[t][z] + conn_TW[t][z] + acc[z]*(h[z]+g[t][z]) ; //(9)
      CAI_tot[t][z] == (CAI_PT[t][z] + CAI_CS[t][z]);//+(1-ww)*(maxl(0, alpha/delta*(delta-Delta[t][z]))*g[t][z]);
     //CAI_tot[t][z] == CAI_PT[t][z] + CAI_CS[t][z]-sum(v in vehicles)((penalty[t][z])^alpha* x[t][v][z]);
      //penalty[t][z] == maxl(0, alpha/delta*(delta-Delta[t][z]));
    }
  forall (t in times, dum in d, z in zones)
   {
     fact_TW[t][z] ==   sum(dum in d) (esp_TW[t][z][dum] * ((1 - minl (1, abs(sum(v in vehicles) y[v][z]-ve[dum])))));
     fact_OW[t][z] ==   sum(dum in d) (esp_OW[t][z][dum] * ((1 - minl (1, abs(sum(v in vehicles) x[t][v][z]-ve[dum])))));
   }
  
  
  forall (t in times, z in zones:CAI_PT[t][z]==0 && dr[1][z]>=1.2 && dr[2][z]>=0.9)
    {
      g[t][z]+h[z]>=1;
    
   }
    
   
  forall (t in times, z in zones)
    {
      h[z] <= 1- g[t][z]; // (11)
    }       
  
  forall (t in times, v in vehicles)
    {
      sum(z in zones)y[v][z] <= 1- sum(z in zones)x[t][v][z]; // (11)
    }     
  
  forall (t in times, v in vehicles)
    {
      sum(z in zones)x[t][v][z] <= 1; // (11)
      sum(z in zones)y[v][z] <= 1;
    }
  
  forall (t in times, z in zones)
    {
      sum(v in vehicles)x[t][v][z] <= num_veh[z]; // (11)
      sum(v in vehicles)y[v][z] <= num_veh[z];
    }
         
 
  forall(t in times, z in zones) 
 	{
 	  forall (v in vehicles)
 	    {
 	            x[t][v][z] <= g[t][z];  //(13)
                y[v][z] <= h[z];
 	    }
      g[t][z] <= sum(v in vehicles) x[t][v][z]; //(14)
      h[z] <= sum(v in vehicles) y[v][z];
 	}
 
 forall(z in zones)
   {
     dep[z]==h[z]+minl (1,sum(t in times)g[t][z]);
     
   }
forall (v in vehicles)
       veh[v] == minl (1,sum(z in zones)y[v][z])+minl (1, sum(t in times,z in zones)x[t][v][z]); 
  value == sum(z in zones)gamma1*dep[z] + sum(v in vehicles)gamma2*veh[v];//  sum(z in zones)( (h[z]+minl (1,sum(t in times)g[t][z])) + gamma2*sum(v in vehicles)(y[v][z]+minl (1, sum(t in times)x[t][v][z])));
  bugdet_constraint: value <= B_CAI; //(17)
   
   tot_veh[1] == sum (z in zones) (T_TW[1][z]);
   tot_veh[2] == sum (z in zones) (T_TW[2][z]);
   
  
  
}





