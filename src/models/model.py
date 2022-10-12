""" model class """

from typing import List


class Model:
    """fake model class"""

    # pylint: disable=redefined-builtin
    def __init__(self, id):
        self.model_id = id

    def train(self):
        """train the model"""
        for i in range(10):
            print(f"training...{i}")

    def predict(self, X: List[int]):
        """
        generate predictions using model

        args:
        -----
        X: a list of integers

        returns:
        preds[dict] - dictionary with the predictions and model_id
        """
        preds = []
        for x_i in X:
            pred = x_i + 10
            preds.append(pred)

        return {"model_id": self.model_id, "predictions": preds}
