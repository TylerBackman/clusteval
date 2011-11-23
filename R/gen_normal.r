#' Generates five multivariate normal populations.
#'
#' We generate \eqn{n_m} observations \eqn({m = 1, \ldots, M})
#' from each of \eqn{M} multivariate normal
#' distributions such that the Euclidean distance between
#' the means of each of the populations is a fixed constant, \eqn{\Delta > 0}.
#'
#' By default, we consider \eqn{M = 5} populations.
#'
#' Let \eqn{\Pi_m} denote the \eqn{m}th population with a \eqn{p}-dimensional
#' multivariate normal distribution, \eqn{N_p(\mu_m, \Sigma_m)} with mean
#' vector \eqn{\mu_m} and covariance matrix \eqn{\Sigma_m}. Also, let
#' \eqn{z_1, \ldots, z_M \sim N_p(0_p, \epsilon I_p)} be independently
#' distributed vectors of noise for a specified \eqn{\epsilon > 0}, where
#' \eqn{0_p} is a \eqn{p \times 1} vector of zeros. Also, let \eqn{e_m} be
#' the \eqn{m}th standard basis vector (i.e. the \eqn{m}th element is 1 and
#' the remaining values are 0). Then, we define \eqn{\mu_m = \Delta e_m + z_m}.
#' We introduce noise to the means to allow for more realistic simulated data set.
#'
#' By default, we let \eqn{\Delta = 0} and \eqn{\epsilon = 0.1}.
#'
#' Also, we considered intraclass covariance (correlation) matrices such that
#' \eqn{\Sigma_m = \sigma^2 (1 - \rho_m) J_p + \rho_m I_p}, where
#' \eqn{-(p-1)^{-1} < \rho_m < 1}, \eqn{I_p} is the \eqn{p \times p} identity matrix,
#' and \eqn{J_p} denotes the \eqn{p \times p} matrix of ones.
#'
#' By default, we let \eqn{\sigma^2 = 1}.
#'
#' We generate \eqn{n_m} observations from population \eqn{\Pi_m}. By default, we
#' generate 10, 30, 50, 70, and 90 observations from populations 1, 2, 3, 4, and 5,
#' respectively.
#'
#' @param n a vector (of length M) of the sample sizes for each population
#' @param p the dimension of the multivariate normal populations
#' @param rho a vector (of length M) of the intraclass constants for each population
#' @param delta the fixed distance between each population
#' @param epsilon the amount of noise to add to the population means.
#' @param sigma2 the coefficient of each intraclass covariance matrix
#' @param seed Seed for random number generation. (If NULL, does not set seed)
#' @return data.frame. The 'Population' column denotes the population from which
#' the observation in each row was generated. The remaining columns in each row
#' contain the generated observation.
#' @export
#' @examples
#' TODO
gen_normal <- function(n = 10 * seq_len(5), p = 100, rho = 0.1 * seq.int(1, 9, by = 2),
delta = 0, epsilon = 0.1, sigma2 = 1, seed = NULL) {
  if (delta < 0) {
    stop("The value for 'delta' must be a nonnegative constant.")
  }
  if (epsilon < 0) {
    stop("The value for 'epsilon' must be a nonnegative constant.")
  }
  if (sigma2 <= 0) {
    stop("The value for 'sigma2' must be positive.")
  }
  if (length(n) != rho) {
    stop("The length of the vectors 'n' and 'rho' must be equal.")
  }
  if(!is.null(seed)) {
    set.seed(seed)
  }

  # The number of populations
  M <- length(n)

  # The multivariate normal noise
  z <- rmvnorm(M, sigma = epsilon * diag(p))

  # A matrix whose rows are the population means.
  means <- delta * diag(1, nrow = M, ncol = p) + z

# TODO: Stopped here.
  pop1 <- c(-1/2, 1/2, delta - 1/2, delta + 1/2)
  pop2 <- c(delta - 1/2, delta + 1/2, -1/2, 1/2)
  pop3 <- c(-1/2, 1/2, -delta - 1/2, -delta + 1/2)
  pop4 <- c(-delta - 1/2, -delta + 1/2, -1/2, 1/2)
  
  unif_pops <- rbind.data.frame(pop1, pop2, pop3, pop4)
  colnames(unif_pops) <- c("a1", "b1", "a2", "b2")
  unif_pops$n <- n
  
  bivar_unif <- function(n, a1, b1, a2, b2) {
    cbind(runif(n, a1, b1), runif(n, a2, b2))
  }
  
  x <- mdply(unif_pops, as.data.frame(bivar_unif), .expand = F)
  colnames(x) <- c("Population", "x1", "x2")
  x$Population <- as.factor(x$Population)  
  x
}

#' Construct an intraclass covariance (correlation) matrix.
#'
#' We define a \eqn{p \times p} intraclass covariance (correlation)
#' matrix to be \eqn{\Sigma_m = \sigma^2 (1 - \rho) J_p + \rho I_p},
#' where \eqn{-(p-1)^{-1} < \rho < 1}, \eqn{I_p} is the
#' \eqn{p \times p} identity matrix, and \eqn{J_p} denotes the
#' \eqn{p \times p} matrix of ones.
#'
#' @param p the dimension of the matrix
#' @param rho the intraclass covariance (correlation) constant
#' @param sigma2 the coefficient of the intraclass covariance matrix
#' @return a square matrix of size p
intraclass_cov <- function(p, rho, sigma2 = 1) {
  if (rho <= -(p-1)^(-1) || rho >= 1) {
    stop("The value for 'rho' must be exclusively between -1 / (p - 1) and 1.")
  }
  if (sigma2 <= 0) {
    stop("The value for 'sigma2' must be positive.")
  }
  sigma2 * ((1 - rho) * matrix(1, nrow = p, ncol = p) + rho * diag(p))
}