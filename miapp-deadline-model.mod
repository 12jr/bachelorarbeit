/*********************************************
 * OPL 12.8.0.0 Model
 *********************************************/

// PARAMETER & ENTSCHEIDUNGSVARIABLEN
	// Job-Parameter
	int	n 		= ...;
	range 	JobsVirtual 	= 0..n;
	range 	JobsReal 	= 1..n;
	float  	d[JobsReal] 	= ...;

	// Kanten-Parameter
	float	t[JobsVirtual, JobsVirtual] = ...;

	// Entscheidungs-Variablen
	dvar boolean	x[JobsVirtual, JobsVirtual];
	dvar float	c[JobsVirtual];
	dvar boolean	u[JobsReal];

	// Pseudo-Entscheidungs-Variable für CPLEX
	dvar float sum_of_t;

// MODELL
	minimize sum(i in JobsReal) u[i];
	subject to {
		//
		forall(j in JobsVirtual)
		  sum(i in JobsVirtual : i!=j) x[i,j] == 1;
		//
		forall(i in JobsVirtual)
		  sum(j in JobsVirtual : j!=i) x[i,j] == 1;
		//
		c[0] == 0;
		//
		forall(i in JobsVirtual, j in JobsReal : i!=j)
		  c[j] >= c[i] + t[i,j] - 2 * sum_of_t * (1 - x[i,j]);
		// 
		forall(i in JobsReal)
		  c[i] - d[i] - sum_of_t * u[i] <= 0;
		//
		forall(i in JobsVirtual)
		  c[i] >= 0;
		
		// sum_of_t berechnen
		sum_of_t == sum(i in JobsVirtual, j in JobsVirtual) t[i,j];
	}

// AUSFÜHRUNG
	execute
	{
		// write found solution to file "res.txt"
		var f=new IloOplOutputFile("res.txt");
		f.writeln(c);
		f.writeln(x);
		f.close();
	}
