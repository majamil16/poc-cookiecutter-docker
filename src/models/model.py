from typing import List


class Model:
    """fake model class"""

    def __init__(self, id):
        self.model_id = id

    def train(self):
        for i in range(10):
            print("training...{i}")

    def predict(self, X: List[int]):
        preds = []
        for x_i in X:
            pred = x_i + 10
            preds.append(pred)

        return {"model_id": self.model_id, "predictions": preds}
