from src.models import Model

model = Model(id="fake_model")


def test_predict():
    """test predict for model."""
    values = [1, 2, 3]
    preds = model.predict(values)

    assert preds == {"model_id": "fake_model", "predictions": [11, 12, 13]}
    print("yay")


if __name__ == "__main__":
    test_predict()
