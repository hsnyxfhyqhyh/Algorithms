package com.ying.algorithm.sorting.bubble01;

public class BubbleSortDemoPractice {
	public static void main(String args[]) {

		int arr[] = { 64, 34, 25, 12, 22, 11, 90 };
		int n = arr.length;
		
		//TODO 
	
		System.out.println("Sorted array");
		printArray(arr);
	}

	/* Prints the array */
	static void printArray(int arr[]) {
		int n = arr.length;
		for (int i = 0; i < n; ++i)
			System.out.print(arr[i] + " ");
		System.out.println();
	}
	
	private static void swapElement (int[] arr, int i, int j) {
		int temp = arr[i]; 
		arr[i] =arr [ j];
		arr[j] =temp; 
	}

}