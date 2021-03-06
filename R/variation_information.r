#' Computes the Variation of Information distance between two clusterings
#'
#' This function calculates Meila's (2007) Variation of Information (VI) metric
#' between two clusterings of the same data set. VI is an information-theoretic
#' criterion that measures the amount of information lost and gained between two
#' clusterings.
#'
#' If \code{n} is the number of observations in the data set, VI is bound
#' between 0 and \code{log(n)}. Furthermore, VI == 0 if and only if the two
#' clusterings are the same.
#'
#' The definition of VI, more properties, and connections to other criteria are
#' given in the Meila (2007) paper, which has open access:
#' \url{http://www.sciencedirect.com/science/article/pii/S0047259X06002016}
#'
#' NOTE: We define 0 log 0 = 0.
#'
#' @export
#' @param labels1 a vector of \code{n} clustering labels
#' @param labels2 a vector of \code{n} clustering labels
#' @return the VI distance between \code{labels1} and \code{labels2}
#' @references Meila, M. (2007). "Comparing clusterings - an information based
#' distance," Journal of Multivariate Analysis, 98, 5, 873-895.
#' \url{http://www.sciencedirect.com/science/article/pii/S0047259X06002016}
#' @examples
#' # We generate K = 3 labels for each of n = 30 observations and compute the
#' # Variation of Information (VI) between the two clusterings.
#' set.seed(42)
#' K <- 3
#' n <- 30
#' labels1 <- sample.int(K, n, replace=TRUE)
#' labels2 <- sample.int(K, n, replace=TRUE)
#' variation_information(labels1, labels2)
#' 
#' # Here, we cluster the \code{\link{iris}} data set with the K-means and
#' # hierarchical algorithms using the true number of clusters, K = 3.
#' # Then, we compute the VI between the two clusterings.
#' iris_kmeans <- kmeans(iris[, -5], centers = 3)$cluster
#' iris_hclust <- cutree(hclust(dist(iris[, -5])), k = 3)
#' variation_information(iris_kmeans, iris_hclust)
variation_information <- function(labels1, labels2) {
  labels1 <- factor(as.vector(labels1))
  labels2 <- factor(as.vector(labels2))
  n <- length(labels1)
  if (n != length(labels2)) {
    stop("The two vectors of cluster labels must be of equal length.")
  }

  # Estimated probability that an observation is assigned to each cluster
  probs1 <- as.numeric(table(labels1) / n)
  probs2 <- as.numeric(table(labels2) / n)

  # Entropy of each clustering: H(C) and H(C')
  H1 <- entropy(probs1)
  H2 <- entropy(probs2)

  joint_probs <- matrix(table(labels1, labels2) / n,
                        nrow=nlevels(labels1))
  product_probs <- outer(probs1, probs2)

  # Mutual Information: I(C, C')
  mutual_information <- sum(joint_probs * log_zero(joint_probs / product_probs))
  
  H1 + H2 - 2 * mutual_information
}

# Entropy based on a vector of probabilities
#
# We define 0 log 0 = 0.
entropy <- function(probs) {
  -drop(probs %*% log_zero(probs))
}

# Logarithm that replaces -Inf with 0
#
# Useful to define 0 log 0 = 0
log_zero <- function(x, base=exp(1)) {
  log_x <- log(x, base=base)
  replace(log_x, log_x == -Inf, 0)
}
