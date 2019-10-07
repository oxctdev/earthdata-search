import RetrievalRequest from '../util/request/retrievalRequest'

import {
  SET_RETRIEVAL_HISTORY,
  SET_RETRIEVAL_HISTORY_LOADING,
  REMOVE_RETRIEVAL_HISTORY
} from '../constants/actionTypes'
import { handleError } from './errors'

export const setRetrievalHistory = retrievalHistoryData => ({
  type: SET_RETRIEVAL_HISTORY,
  payload: retrievalHistoryData
})

export const setRetrievalHistoryLoading = () => ({
  type: SET_RETRIEVAL_HISTORY_LOADING
})

export const removeRetrievalHistory = retrievalId => ({
  type: REMOVE_RETRIEVAL_HISTORY,
  payload: retrievalId
})

/**
 * Fetch a retrieval from the database
 */
export const fetchRetrievalHistory = () => (dispatch, getState) => {
  const { authToken } = getState()

  dispatch(setRetrievalHistoryLoading())

  const requestObject = new RetrievalRequest(authToken)
  const response = requestObject.all()
    .then((response) => {
      const { data } = response

      dispatch(setRetrievalHistory(data))
    })
    .catch((error) => {
      dispatch(handleError({
        error,
        action: 'fetchRetrievalHistory',
        resource: 'retrieval history'
      }))
    })

  return response
}