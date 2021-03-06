module MachineLearning.RegressionTest
(
  tests
)

where

import Test.Framework (testGroup)
import Test.Framework.Providers.HUnit
import Test.HUnit
import Test.HUnit.Approx
import Test.HUnit.Plus

import qualified Numeric.LinearAlgebra as LA

import MachineLearning.DataSets (dataset1)

import qualified MachineLearning as ML
import MachineLearning.Regression

(x, y) = ML.splitToXY dataset1

muSigma = ML.meanStddev x
xNorm = ML.featureNormalization muSigma x
x1 = ML.addBiasDimension xNorm
zeroTheta = LA.konst 0 (LA.cols x1)

xPredict = LA.matrix 2 [1650, 3]
xPredict1 = ML.addBiasDimension $ ML.featureNormalization muSigma xPredict

theta = normalEquation (ML.addBiasDimension x) y
yExpected = hypothesis LeastSquares (ML.addBiasDimension xPredict) theta

eps = 0.0001
thetaNE = normalEquation x1 y
thetaNE_p = normalEquation_p x1 y
(thetaGD, _) = minimize (GradientDescent 0.01) LeastSquares eps 5000 RegNone x1 y zeroTheta
(thetaMBGD, _) = minimize (MinibatchGradientDescent 11711 64 0.05) LeastSquares eps 5000 RegNone x1 y zeroTheta
(thetaCGFR, _) = minimize (ConjugateGradientFR 0.1 0.1) LeastSquares eps 1500 RegNone x1 y zeroTheta
(thetaCGPR, _) = minimize (ConjugateGradientPR 0.1 0.1) LeastSquares eps 1500 RegNone x1 y zeroTheta
(thetaBFGS, _) = minimize (BFGS2 0.1 0.1) LeastSquares eps 1500 RegNone x1 y zeroTheta


tests = [ testGroup "minimize" [
            testCase "Normal Equation" $ assertVector "" 0.01 yExpected (hypothesis LeastSquares xPredict1 thetaNE)
            , testCase "Normal Equation using pseudo inverse" $ assertVector "" 0.01 yExpected (hypothesis LeastSquares xPredict1 thetaNE_p)
            , testCase "Gradient Descent" $ assertVector "" 0.01 yExpected (hypothesis LeastSquares xPredict1 thetaGD)
            , testCase "Minibatch Gradient Descent" $ assertVector "" 1100 yExpected (hypothesis LeastSquares xPredict1 thetaMBGD)
            , testCase "BFGS" $ assertVector "" 0.01 yExpected (hypothesis LeastSquares xPredict1 thetaBFGS)
            , testCase "Conjugate Gradient FR" $ assertVector "" 0.01 yExpected (hypothesis LeastSquares xPredict1 thetaCGFR)
            , testCase "Conjugate Gradient PR" $ assertVector "" 0.01 yExpected (hypothesis LeastSquares xPredict1 thetaCGPR)
            ]
        ]
