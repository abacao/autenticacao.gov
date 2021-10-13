﻿using System;
using System.Text;

namespace eidpt
{
	
	public class PteidException : ApplicationException
	{

	  public PteidException() : base("Generic error")
	  {
		
	  }
	  
	  public PteidException(int error_code): base("Error code : " +error_code.ToString("X4"))
	  {
		
	  }
		
	}

}
