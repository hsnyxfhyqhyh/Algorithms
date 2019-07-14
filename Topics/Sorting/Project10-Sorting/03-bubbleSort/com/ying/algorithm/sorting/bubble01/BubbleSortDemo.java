package com.ying.algorithm.sorting.bubble01;

public class BubbleSortDemo {
	public static void main(String args[]) {
		
		int arr[] = { 64, 34, 25, 12, 22, 11, 90 };

		//Sorting logic  - starts . 
		int n = arr.length;
		for (int i = 0; i < n - 1; i++) {
			for (int j = 0; j < n - i - 1; j++) {
				if (arr[j] > arr[j + 1]) {
					// swap arr[j+1] and arr[i]
					int temp = arr[j];
					arr[j] = arr[j + 1];
					arr[j + 1] = temp;
				}
			}
		}
		//Sorting logic  - ends.
		
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
}
