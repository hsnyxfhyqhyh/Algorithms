package com.ying.algorithm.sorting.selection01;

/*
 * To practice the sorting logic. 
 */
public class SelectionSortingDemoPractice {

	// Driver code to test above
	public static void main(String args[]) {
		int arr[] = { 64, 25, 12, 22, 11 , 78, 33};
		
		int n = arr.length;

		//TODO: sorting logic implemented here. 
		
		
		
		System.out.println("Sorted array");
		
		printArray(arr);
	}


	// Prints the array
	private static void printArray(int arr[]) {
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
