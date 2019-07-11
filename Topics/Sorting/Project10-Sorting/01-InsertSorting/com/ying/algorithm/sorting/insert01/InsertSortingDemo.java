package com.ying.algorithm.sorting.insert01;

/*
 * Data Structures and Algorithms By Michael T. Goodrich.  p111-Code Fragment 3.6.
 */
public class InsertSortingDemo {

	public static void main(String[] args) {

		char [] data = {'B', 'C', 'D', 'A', 'E', 'H', 'G', 'F'};
		
			printCharArray(data);
		
		insertionSort(data);
		
			System.out.println("");
		
		printCharArray(data);
		
			System.out.println("");
	}
	
	public static void insertionSort(char[] data) {
		int n = data.length; 
		
		for (int k=1; k<n; k++) {
			char cur =data[k]; 
			int j = k ;
			while (j>0 && data[j-1] > cur) {
				data[j] = data[j-1]; 
				j--; 
			}
			
			data[j] = cur; 					//this is the proper place for cur
		}
	}
	
	public static void printCharArray(char[] data) {
		int n = data.length; 
		
		for (int k=0; k<n; k++) {
			System.out.print(data[k]);
		}
	}

}
