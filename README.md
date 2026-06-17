# TSCSSL
The use of unsupervised machine learning for clustering and interpreting hydrogeochemical processes is often limited by the difficulty of interpreting the results, especially when multiple controlling factors produce a large number of clusters. However, adjusting the model to reduce the number of classes may lead to substantial intra-class variability in some groups. To interpret this intra-group difference without altering the initial unsupervised clustering, we developed a typical sample-constrained semi-supervised hydrochemical classification method (TSCSSL)
<img width="1880" height="970" alt="workflow" src="https://github.com/user-attachments/assets/385e0b67-9c0a-41fb-9a4c-37964d093142" />
Workflow of the Typical Sample-Constrained Semi-Supervised Machine Learning (TSCSSL) hydrochemical classification method

In theory, it can be used as a post-processing step for any unsupervised learning method. In this study, we used self-organizing maps combined with K-means clustering.

In our case study, Na, B, and Cl were selected as the classification basis according to the hydrogeochemical mechanisms involved in geothermal system evolution. Based on well-established previous studies, some geothermal springs with relatively clear genetic mechanisms were selected as typical samples, and two patterns were constructed in advance. The integrated distance from each unknown sample to the two patterns was then calculated using the ionic ratios and linear relationships among Na, B, and Cl. Each unknown sample was finally assigned to the class with the smaller integrated distance.

For our case study, the input file should be provided as an Excel file named `water_data.xlsx`, with at least three required columns: Na, Cl, and B. The code should be executed using MATLAB R2023b or later.
Finally, the code generates an Excel file named `classification_result.xlsx`, which includes key data such as the classification results, the integrated distance for each sample, and the classification confidence index. In addition, three plots are produced, including Na–Cl, B–Cl, and Na/Cl–B/Cl diagrams, for direct and convenient visualization of distribution differences.

License
This project is released under the MIT License.
