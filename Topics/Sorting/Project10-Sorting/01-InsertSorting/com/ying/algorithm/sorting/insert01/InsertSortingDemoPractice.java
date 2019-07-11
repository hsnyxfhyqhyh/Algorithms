package com.ying.algorithm.sorting.insert01;

public class InsertSortingDemoPractice {

	public static void main(String[] args) {
		char[] data = {'B', 'D', 'C', 'A', 'G', 'E', 'H'} ; 
		
		int length = data.length; 
		
		for (int k= 1; k < length; k++) {
			char cur = data[k]; 
			
			int j=k; 
			
			while (j>0 && data[j] < data[j-1]) {
				data[j] = data[j-1]; 
				j--; 
			}
			
			data [k] = cur; 
			
		}
		
		System.out.println(data);

	}

}
